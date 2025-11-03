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
  
  // Debug: Log state changes
  useEffect(() => {
    console.log("[CallControlRibbon] isDeviceRegistered changed to:", isDeviceRegistered);
  }, [isDeviceRegistered]);

  useEffect(() => {
    console.log("[CallControlRibbon] isCallActive changed to:", isCallActive);
  }, [isCallActive]);

  // Debug: Log config on mount
  useEffect(() => {
    console.log("====================================================================");
    console.log("[CallControlRibbon] INITIALIZATION DEBUG INFO");
    console.log("====================================================================");
    console.log("[CallControlRibbon] Config object:", JSON.stringify(config, null, 2));
    console.log("[CallControlRibbon] accessToken:", config?.accessToken?.substring(0, 20) + "...");
    console.log("[CallControlRibbon] userId:", config?.userId);
    console.log("====================================================================");
  }, [config]);
  const [isMuted, setIsMuted] = useState(false);
  const [isOnHold, setIsOnHold] = useState(false);
  const [isIncomingCall, setIsIncomingCall] = useState(false);
  const [showNotification, setShowNotification] = useState(false);
  const [notificationMessage, setNotificationMessage] = useState("");
  const [notificationType, setNotificationType] = useState("info");
  const [isDialing, setIsDialing] = useState(false);
  const [currentCall, setCurrentCall] = useState(null);
  const [minimized, setMinimized] = useState(initialMinimized);
  const [callDuration, setCallDuration] = useState(0);
  const [showDTMF, setShowDTMF] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const [dragOffset, setDragOffset] = useState({ x: 0, y: 0 });
  const [dragPosition, setDragPosition] = useState({ x: 0, y: 0 });
  
  const webPhone = useRef(null);
  const ribbonRef = useRef(null);
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
    console.log("====================================================================");
    console.log("[CallControlRibbon] REGISTRATION EVENT:", event);
    console.log("====================================================================");
    if (event === "registered") {
      console.log("✅ Device registered successfully!");
      setIsDeviceRegistered(true);
      onReady?.();
      showNotificationMessage("Device online", "success");
    }
    if (event === "unregistered") {
      console.log("❌ Device unregistered!");
      setIsDeviceRegistered(false);
      showNotificationMessage("Device offline", "error");
    }
  };

  useEffect(() => {
    const initializePhone = async () => {
      if (webPhone.current) {
        return;
      }
      
      // Validate credentials
      if (!config?.accessToken || !config?.userId) {
        console.error("[CallControlRibbon] Missing Exotel credentials");
        showNotificationMessage("Missing Exotel credentials", "error");
        return;
      }
      
      try {
        console.log("====================================================================");
        console.log("[CallControlRibbon] INITIALIZING EXOTEL SDK");
        console.log("====================================================================");
        console.log("[CallControlRibbon] Creating ExotelCRMWebSDK instance...");
        const crmWebSDK = new ExotelCRMWebSDK(config.accessToken, config.userId, true);
        console.log("[CallControlRibbon] Calling Initialize...");
        const crmWebPhone = await crmWebSDK.Initialize(
          HandleCallEvents,
          RegisterationEvent
        );
        webPhone.current = crmWebPhone;
        console.log("✅ [CallControlRibbon] Exotel SDK initialized successfully!");
        console.log("====================================================================");
      } catch (error) {
        console.error("====================================================================");
        console.error("[CallControlRibbon] INITIALIZATION FAILED:", error);
        console.error("Error details:", JSON.stringify(error, null, 2));
        console.error("====================================================================");
        showNotificationMessage("Failed to initialize call service", "error");
      }
    };

    initializePhone();

    return () => {
      if (callTimer.current) {
        clearInterval(callTimer.current);
      }
      // Clean up webPhone reference
      if (webPhone.current) {
        webPhone.current = null;
      }
    };
  }, [config]);

  // Keyboard shortcuts for accessibility
  useEffect(() => {
    const handleKeyPress = (e) => {
      // Only handle shortcuts when ribbon is not minimized and has focus
      if (minimized) return;
      
      const isCtrlOrCmd = e.ctrlKey || e.metaKey;
      const isShift = e.shiftKey;
      
      if (isCtrlOrCmd) {
        switch(e.key.toLowerCase()) {
          case 'd':
            e.preventDefault();
            if (!isCallActive && !isIncomingCall && !isDialing) {
              dial();
            }
            break;
          case 'm':
            e.preventDefault();
            if (isCallActive) {
              onClickToggleMute();
            }
            break;
          case 'h':
            e.preventDefault();
            if (isCallActive) {
              onClickToggleHold();
            }
            break;
          case 'c':
            e.preventDefault();
            if (isCallActive) {
              hangup();
            }
            break;
          case 'enter':
            e.preventDefault();
            if (e.target.className.includes('ribbon-phone-input')) {
              dial();
            }
            break;
        }
      }
      
      // Space bar to minimize/expand
      if (e.code === 'Space' && e.target === document.body) {
        e.preventDefault();
        setMinimized(!minimized);
      }
    };

    document.addEventListener('keydown', handleKeyPress);
    return () => document.removeEventListener('keydown', handleKeyPress);
  }, [minimized, isCallActive, isIncomingCall, isDialing, phoneNumber]);

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
    setNotificationType(type);
    setShowNotification(true);
    setTimeout(() => {
      setShowNotification(false);
    }, 4000);
  };

  const getNotificationIcon = (type) => {
    switch (type) {
      case 'success': return '✅';
      case 'error': return '❌';
      case 'warning': return '⚠️';
      default: return 'ℹ️';
    }
  };

  const dialCallback = (status, response) => {
    console.log("====================================================================");
    console.log("[CallControlRibbon] dialCallback called");
    console.log("====================================================================");
    console.log("[CallControlRibbon] Status:", status);
    console.log("[CallControlRibbon] Response:", JSON.stringify(response, null, 2));
    if (status === "success") {
      const callSid = response.Data?.CallSid;
      console.log("[CallControlRibbon] CallSid:", callSid);
      console.log("✅ Call initiated successfully!");
    } else {
      console.log("❌ Call failed in callback");
    }
    console.log("====================================================================");
  };

  const dial = () => {
    if (!phoneNumber || !/^\+?[0-9]{10,14}$/.test(phoneNumber)) {
      showNotificationMessage("Invalid phone number", "error");
      return;
    }

    console.log("[CallControlRibbon] Dialling:", phoneNumber);
    console.log("[CallControlRibbon] webPhone.current:", webPhone.current);
    console.log("[CallControlRibbon] config:", config);
    setIsDialing(true);
    setIsIncomingCall(false);
    showNotificationMessage(`Dialling ${phoneNumber}`, "info");
    
    if (!webPhone.current) {
      console.error("[CallControlRibbon] Cannot make call - webPhone not initialized");
      showNotificationMessage("Call service not available", "error");
      setIsDialing(false);
      return;
    }
    
    try {
      console.log("====================================================================");
      console.log("[CallControlRibbon] CALL DEBUG INFO");
      console.log("====================================================================");
      console.log("[CallControlRibbon] Phone number:", phoneNumber);
      console.log("[CallControlRibbon] Config:", JSON.stringify(config, null, 2));
      console.log("[CallControlRibbon] webPhone available:", !!webPhone.current);
      if (webPhone.current) {
        console.log("[CallControlRibbon] webPhone methods:", Object.getOwnPropertyNames(webPhone.current));
        console.log("[CallControlRibbon] MakeCall exists:", typeof webPhone.current.MakeCall);
      }
      console.log("====================================================================");
      
      // MakeCall with callback as per SDK documentation
      webPhone.current.MakeCall(phoneNumber, dialCallback);
      
    } catch (error) {
      console.error("====================================================================");
      console.error("[CallControlRibbon] MakeCall ERROR DETAILS:");
      console.error("Error:", error);
      console.error("Error message:", error.message);
      console.error("Error stack:", error.stack);
      if (error.Error) {
        console.error("Error body:", JSON.parse(error.Error));
      }
      console.error("====================================================================");
      showNotificationMessage(`Call failed: ${error.message || 'Unknown error'}`, "error");
      setIsDialing(false);
    }
    
    // Reset dialing state after a delay
    setTimeout(() => {
      setIsDialing(false);
    }, 2000);
  };

  const acceptCall = () => {
    webPhone?.current?.AcceptCall();
    setCallActive(true);
    setIsIncomingCall(false);
    setIsMuted(false);
    setIsOnHold(false);
  };

  const hangup = () => {
    if (webPhone.current) {
      webPhone.current.HangupCall();
    }
    if (callTimer.current) {
      clearInterval(callTimer.current);
      callTimer.current = null;
    }
    setCallActive(false);
    setCallDuration(0);
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
    setIsMuted((prev) => {
      const newMutedState = !prev;
      showNotificationMessage(newMutedState ? "Call muted" : "Call unmuted", "info");
      return newMutedState;
    });
  };

  const handleToggleOnHold = () => {
    setIsOnHold((prev) => {
      const newHoldState = !prev;
      showNotificationMessage(newHoldState ? "Call on hold" : "Call resumed", "info");
      return newHoldState;
    });
  };

  const onClickToggleHold = () => {
    debounceClick(lastHoldClick, () => {
      webPhone?.current?.ToggleHold();
    });
  };

  const sendDTMF = (digit) => {
    webPhone?.current?.SendDTMF(digit.toString());
  };

  // Drag functionality
  const handleDragStart = (e) => {
    // Only allow dragging from the header area
    if (!e.target.closest('.ribbon-header')) return;
    
    setIsDragging(true);
    
    if (e.type === 'mousedown') {
      setDragOffset({
        x: e.clientX,
        y: e.clientY
      });
    } else if (e.type === 'touchstart') {
      const touch = e.touches[0];
      setDragOffset({
        x: touch.clientX,
        y: touch.clientY
      });
    }
    
    e.preventDefault();
  };

  const handleDragMove = (e) => {
    if (!isDragging) return;
    
    let clientX, clientY;
    
    if (e.type === 'mousemove') {
      clientX = e.clientX;
      clientY = e.clientY;
    } else if (e.type === 'touchmove') {
      const touch = e.touches[0];
      clientX = touch.clientX;
      clientY = touch.clientY;
    }
    
    // Simple direct movement - no complex bounds checking for now
    const deltaX = clientX - dragOffset.x;
    const deltaY = clientY - dragOffset.y;
    
    setDragPosition({ x: deltaX, y: deltaY });
    e.preventDefault();
  };

  const handleDragEnd = () => {
    setIsDragging(false);
  };

  // Add event listeners for drag functionality
  useEffect(() => {
    if (isDragging) {
      document.addEventListener('mousemove', handleDragMove);
      document.addEventListener('mouseup', handleDragEnd);
      document.addEventListener('touchmove', handleDragMove);
      document.addEventListener('touchend', handleDragEnd);
    }

    return () => {
      document.removeEventListener('mousemove', handleDragMove);
      document.removeEventListener('mouseup', handleDragEnd);
      document.removeEventListener('touchmove', handleDragMove);
      document.removeEventListener('touchend', handleDragEnd);
    };
  }, [isDragging, dragOffset]);

  // Log credential status
  if (!config?.accessToken || !config?.userId) {
    console.warn("[CallControlRibbon] Missing Exotel credentials");
  }

  return (
    <div 
      ref={ribbonRef}
      className={`call-ribbon call-ribbon-${position} ${minimized ? 'minimized' : ''} ${isDragging ? 'dragging' : ''}`}
      role="complementary"
      aria-label="Call Control Panel"
      aria-live="polite"
      tabIndex={-1}
      style={{
        zIndex: 9999,
        transform: dragPosition.x !== 0 || dragPosition.y !== 0 
          ? `translate(${dragPosition.x}px, ${dragPosition.y}px)` 
          : undefined
      }}
      onMouseDown={handleDragStart}
      onTouchStart={handleDragStart}
    >
      {/* Screen Reader Status */}
      <div className="sr-only" aria-live="assertive">
        {isDeviceRegistered ? 'Call service online' : 'Call service offline'}
        {isCallActive ? `, Call active for ${formatDuration(callDuration)}` : ''}
        {isIncomingCall ? ', Incoming call' : ''}
        {isMuted ? ', Call muted' : ''}
        {isOnHold ? ', Call on hold' : ''}
      </div>

      {/* Enhanced Notification Bar */}
      {showNotification && (
        <div className={`ribbon-notification ${notificationType}`} role="alert">
          <span className="notification-icon" aria-hidden="true">{getNotificationIcon(notificationType)}</span>
          {notificationMessage}
        </div>
      )}

        {/* Header Bar - Prominence Style */}
        <div className="ribbon-header">
          <div className="ribbon-title">
            <span className={`status-dot ${isDeviceRegistered ? 'online' : 'offline'}`}></span>
            <span className="title-text">
              {isCallActive ? 'IntalksAI Callhub - Active Call' : 'IntalksAI Callhub'}
            </span>
              <span className="drag-handle" title="Drag to move">⋮⋮</span>
          </div>
          
          {customerData?.name && (
            <div className="customer-info">
              <span className="customer-name">{customerData.name} ({phoneNumber})</span>
            </div>
          )}

          <button 
            className="ribbon-toggle"
            onClick={() => setMinimized(!minimized)}
            title={minimized ? "Expand" : "Minimize"}
            aria-label={minimized ? "Expand call control panel" : "Minimize call control panel"}
          >
            {minimized ? '▲' : '▼'}
          </button>
        </div>

      {/* Ribbon Content */}
      {!minimized && (
        <div className="ribbon-content">
          {console.log("[CallControlRibbon] Render: isDeviceRegistered =", isDeviceRegistered)}
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
                  <button 
                    className={`ribbon-btn ribbon-btn-dial ${isDialing ? 'loading' : ''}`}
                    onClick={dial}
                    disabled={isDialing}
                  >
                    {isDialing ? 'Dialing...' : '📞 Dial'}
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

              {/* Active Call Controls - Modern Horizontal Style */}
              {isCallActive && (
                <div className="ribbon-controls-modern">
                  <span className="call-timer">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8z"/>
                      <path d="M12.5 7H11v6l5.25 3.15.75-1.23-4.5-2.67z"/>
                    </svg>
                    {formatDuration(callDuration)}
                  </span>
                  
                  <button 
                    className={`control-btn ${isMuted ? 'active' : ''}`}
                    onClick={onClickToggleMute}
                    title={isMuted ? "Unmute" : "Mute"}
                  >
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                      {isMuted ? (
                        <path d="M19 11h-1.7c0 .74-.16 1.43-.43 2.05l1.23 1.23c.56-.98.9-2.09.9-3.28zm-4.02.17c0-.06.02-.11.02-.17V5c0-1.66-1.34-3-3-3S9 3.34 9 5v.18l5.98 5.99zM4.27 3L3 4.27 6.01 7.3C6 7.46 6 7.73 6 8v6h4v6l2-2h2.73l4.73 4.73L21 19.73l-7-7.01L4.27 3z"/>
                      ) : (
                        <path d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3zm5.3-3c0 3-2.54 5.1-5.3 5.1S6.7 14 6.7 11H5c0 3.41 2.72 6.23 6 6.72V21h2v-3.28c3.28-.48 6-3.3 6-6.72h-1.7z"/>
                      )}
                    </svg>
                  </button>
                  
                  <button 
                    className={`control-btn ${isOnHold ? 'active' : ''}`}
                    onClick={onClickToggleHold}
                    title={isOnHold ? "Resume" : "Hold"}
                  >
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                      {isOnHold ? (
                        <path d="M8 5v14l11-7z"/>
                      ) : (
                        <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
                      )}
                    </svg>
                  </button>

                  <button 
                    className="control-btn"
                    onClick={() => showNotificationMessage("Add Participant feature coming soon", "info")}
                    title="Add Participant"
                  >
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14zm-1-9h-2v2h-2v-2h-2V9h2V7h2v2h2v2z"/>
                    </svg>
                  </button>

                  <button 
                    className="control-btn hangup-btn"
                    onClick={hangup}
                    title="Hang Up"
                  >
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"/>
                    </svg>
                  </button>
                </div>
              )}

              {/* DTMF Keypad - Collapsible */}
              {isCallActive && (
                <div className="ribbon-dtmf">
                  <div className="dtmf-header">
                    <span>DTMF Keypad</span>
                    <button 
                      className="dtmf-toggle"
                      onClick={() => setShowDTMF(!showDTMF)}
                      title="Toggle Keypad"
                    >
                      🔢
                    </button>
                  </div>
                  {showDTMF && (
                    <div className="dtmf-grid">
                      {[1, 2, 3, 4, 5, 6, 7, 8, 9, '*', 0, '#'].map((digit) => (
                        <button
                          key={digit}
                          className={`dtmf-btn ${['*', '#'].includes(digit) ? 'special' : ''}`}
                          onClick={() => sendDTMF(digit)}
                        >
                          {digit}
                        </button>
                      ))}
                    </div>
                  )}
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
