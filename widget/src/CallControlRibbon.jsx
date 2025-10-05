import React, { useEffect, useState, useRef } from "react";
import ExotelCRMWebSDK from "exotel-ip-calling-crm-websdk";
import "./CallControlRibbon.css";

/**
 * Call Control Ribbon - A reusable component for CRM integration
 * 
 * Props:
 * - config: { accessToken, userId } - Exotel credentials
 * - customerData: { phoneNumber, name, email, customerId } - Customer information
 * - position: 'top' | 'bottom' | 'floating' - Ribbon position
 * - onCallEvent: (event, data) => {} - Callback for call events
 * - onReady: () => {} - Callback when ribbon is ready
 */
const CallControlRibbon = ({
  config,
  customerData = {},
  position = 'bottom',
  onCallEvent,
  onReady,
  minimized: initialMinimized = false
}) => {
  const [phoneNumber, setPhoneNumber] = useState(customerData?.phoneNumber || "");
  const [isCallActive, setCallActive] = useState(false);
  const [isDeviceRegistered, setIsDeviceRegistered] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [isOnHold, setIsOnHold] = useState(false);
  const [isIncomingCall, setIsIncomingCall] = useState(false);
  const [showNotification, setShowNotification] = useState(false);
  const [notificationMessage, setNotificationMessage] = useState("");
  const [currentCall, setCurrentCall] = useState(null);
  const [minimized, setMinimized] = useState(initialMinimized);
  const [callDuration, setCallDuration] = useState(0);
  
  const webPhone = useRef(null);
  const callTimer = useRef(null);
  const lastMuteClick = useRef(0);
  const lastHoldClick = useRef(0);

  // Update phone number when customerData changes
  useEffect(() => {
    if (customerData?.phoneNumber) {
      setPhoneNumber(customerData.phoneNumber);
    }
  }, [customerData?.phoneNumber]);

  const HandleCallEvents = (eventType, ...args) => {
    console.log("[CallControlRibbon] HandleCallEvents", eventType, { args });
    const callData = args[0];
    
    // Notify parent application
    onCallEvent?.(eventType, {
      ...callData,
      customerData,
      timestamp: new Date().toISOString()
    });

    switch (eventType) {
      case "incoming":
        setIsIncomingCall(true);
        setCurrentCall(callData);
        showNotificationMessage("Incoming call...", "info");
        break;
      case "connected":
        setCallActive(true);
        setIsIncomingCall(false);
        setCurrentCall(callData);
        startCallTimer();
        showNotificationMessage("Call connected", "success");
        break;
      case "callEnded":
        setCallActive(false);
        setIsIncomingCall(false);
        setIsMuted(false);
        setIsOnHold(false);
        setCurrentCall(null);
        stopCallTimer();
        showNotificationMessage("Call ended", "info");
        break;
      case "holdtoggle":
        handleToggleOnHold();
        break;
      case "mutetoggle":
        handleToggleMute();
        break;
      default:
        break;
    }
  };

  const RegisterationEvent = (event) => {
    if (event === "registered") {
      setIsDeviceRegistered(true);
      onReady?.();
      showNotificationMessage("Device online", "success");
    }
    if (event === "unregistered") {
      setIsDeviceRegistered(false);
      showNotificationMessage("Device offline", "error");
    }
  };

  useEffect(() => {
    const initializePhone = async () => {
      if (webPhone.current || !config?.accessToken || !config?.userId) {
        return;
      }
      
      try {
        console.log("[CallControlRibbon] Initializing Exotel SDK");
        const crmWebSDK = new ExotelCRMWebSDK(config.accessToken, config.userId, true);
        const crmWebPhone = await crmWebSDK.Initialize(
          HandleCallEvents,
          RegisterationEvent
        );
        webPhone.current = crmWebPhone;
        console.log("[CallControlRibbon] Exotel SDK initialized");
      } catch (error) {
        console.error("[CallControlRibbon] Initialization failed:", error);
        showNotificationMessage("Failed to initialize call service", "error");
      }
    };

    initializePhone();

    return () => {
      if (callTimer.current) {
        clearInterval(callTimer.current);
      }
    };
  }, [config]);

  const startCallTimer = () => {
    setCallDuration(0);
    callTimer.current = setInterval(() => {
      setCallDuration(prev => prev + 1);
    }, 1000);
  };

  const stopCallTimer = () => {
    if (callTimer.current) {
      clearInterval(callTimer.current);
      callTimer.current = null;
    }
    setCallDuration(0);
  };

  const formatDuration = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const showNotificationMessage = (message, type = "info") => {
    setNotificationMessage(message);
    setShowNotification(true);
    setTimeout(() => {
      setShowNotification(false);
    }, 3000);
  };

  const dialCallback = (status, response) => {
    console.log("[CallControlRibbon] dialCallback", { status, response });
    if (status === "success") {
      const callSid = response.Data?.CallSid;
      console.log("[CallControlRibbon] CallSid:", callSid);
    }
  };

  const dial = () => {
    if (!phoneNumber || !/^\+?[0-9]{10,14}$/.test(phoneNumber)) {
      showNotificationMessage("Invalid phone number", "error");
      return;
    }

    if (!webPhone.current) {
      showNotificationMessage("Call service not ready", "error");
      return;
    }

    console.log("[CallControlRibbon] Dialling:", phoneNumber);
    setCallActive(true);
    setIsIncomingCall(false);
    showNotificationMessage(`Dialling ${phoneNumber}`, "info");
    webPhone.current.MakeCall(phoneNumber, dialCallback);
  };

  const acceptCall = () => {
    webPhone?.current?.AcceptCall();
    setCallActive(true);
    setIsIncomingCall(false);
    setIsMuted(false);
    setIsOnHold(false);
  };

  const hangup = () => {
    webPhone?.current?.HangupCall();
    setCallActive(false);
  };

  const debounceClick = (ref, callback, delay = 500) => {
    const now = Date.now();
    if (now - ref.current < delay) return;
    ref.current = now;
    callback();
  };

  const onClickToggleMute = () => {
    debounceClick(lastMuteClick, () => {
      webPhone?.current?.ToggleMute();
    });
  };

  const handleToggleMute = () => {
    setIsMuted((prev) => !prev);
    showNotificationMessage(isMuted ? "Call unmuted" : "Call muted", "info");
  };

  const handleToggleOnHold = () => {
    setIsOnHold((prev) => !prev);
    showNotificationMessage(isOnHold ? "Call resumed" : "Call on hold", "info");
  };

  const onClickToggleHold = () => {
    debounceClick(lastHoldClick, () => {
      webPhone?.current?.ToggleHold();
    });
  };

  const sendDTMF = (digit) => {
    webPhone?.current?.SendDTMF(digit.toString());
  };

  if (!config?.accessToken || !config?.userId) {
    return (
      <div className={`call-ribbon call-ribbon-${position}`}>
        <div className="ribbon-error">
          ⚠️ Call Control: Missing configuration
        </div>
      </div>
    );
  }

  return (
    <div className={`call-ribbon call-ribbon-${position} ${minimized ? 'minimized' : ''}`}>
      {/* Notification Bar */}
      {showNotification && (
        <div className="ribbon-notification">
          {notificationMessage}
        </div>
      )}

      {/* Header Bar */}
      <div className="ribbon-header">
        <div className="ribbon-title">
          <span className={`status-dot ${isDeviceRegistered ? 'online' : 'offline'}`}></span>
          <span className="title-text">
            {isCallActive ? `Call Active ${formatDuration(callDuration)}` : 'Call Control'}
          </span>
        </div>
        
        {customerData?.name && (
          <div className="customer-info">
            <span className="customer-name">{customerData.name}</span>
          </div>
        )}

        <button 
          className="ribbon-toggle"
          onClick={() => setMinimized(!minimized)}
          title={minimized ? "Expand" : "Minimize"}
        >
          {minimized ? '▲' : '▼'}
        </button>
      </div>

      {/* Ribbon Content */}
      {!minimized && (
        <div className="ribbon-content">
          {!isDeviceRegistered ? (
            <div className="ribbon-status">Connecting to Exotel...</div>
          ) : (
            <>
              {/* Phone Input */}
              {!isCallActive && !isIncomingCall && (
                <div className="ribbon-input-group">
                  <input
                    className="ribbon-phone-input"
                    type="text"
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    placeholder="Enter phone number"
                  />
                  <button className="ribbon-btn ribbon-btn-dial" onClick={dial}>
                    📞 Dial
                  </button>
                </div>
              )}

              {/* Incoming Call */}
              {isIncomingCall && (
                <div className="ribbon-incoming">
                  <span className="incoming-text">Incoming call...</span>
                  <button className="ribbon-btn ribbon-btn-accept" onClick={acceptCall}>
                    ✓ Accept
                  </button>
                  <button className="ribbon-btn ribbon-btn-reject" onClick={hangup}>
                    ✗ Reject
                  </button>
                </div>
              )}

              {/* Active Call Controls */}
              {isCallActive && (
                <div className="ribbon-controls">
                  <button 
                    className={`ribbon-btn ribbon-btn-icon ${isMuted ? 'active' : ''}`}
                    onClick={onClickToggleMute}
                    title={isMuted ? "Unmute" : "Mute"}
                  >
                    {isMuted ? '🔇' : '🔊'}
                  </button>
                  
                  <button 
                    className={`ribbon-btn ribbon-btn-icon ${isOnHold ? 'active' : ''}`}
                    onClick={onClickToggleHold}
                    title={isOnHold ? "Resume" : "Hold"}
                  >
                    {isOnHold ? '▶️' : '⏸️'}
                  </button>

                  <button 
                    className="ribbon-btn ribbon-btn-hangup"
                    onClick={hangup}
                  >
                    📞 Hangup
                  </button>

                  {/* DTMF Keypad */}
                  <div className="ribbon-dtmf">
                    {[1, 2, 3, 4, 5, 6, 7, 8, 9, '*', 0, '#'].map((digit) => (
                      <button
                        key={digit}
                        className="dtmf-btn"
                        onClick={() => sendDTMF(digit)}
                      >
                        {digit}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      )}
    </div>
  );
};

export default CallControlRibbon;
