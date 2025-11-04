/**
 * Exotel Call Control Ribbon - Widget Entry Point
 * 
 * This file creates a global API that can be embedded in any website/CRM
 * Usage:
 *   <script src="https://cdn.yourcompany.com/ribbon/v1/ribbon.js"></script>
 *   <script>
 *     IntalksAICallRibbon.init({ apiKey: 'xxx', position: 'bottom' });
 *   </script>
 */

import React from 'react';
import ReactDOM from 'react-dom/client';
import CallControlRibbon from './CallControlRibbon';

class IntalksAICallRibbonWidget {
  constructor() {
    this.root = null;
    this.container = null;
    this.config = null;
    this.credentials = null;
    this.customerData = null;
  }

  /**
   * Initialize the ribbon widget
   * @param {Object} config - Configuration object
   * @param {string} config.apiKey - Client's API key (provided by you)
   * @param {string} config.agentUserId - Agent's unique user ID (optional but recommended)
   * @param {string} config.clientName - Client/company name (optional but recommended)
   * @param {string} config.position - Ribbon position: 'top', 'bottom', or 'floating'
   * @param {Function} config.onCallEvent - Callback for call events
   * @param {Function} config.onReady - Callback when ribbon is ready
   * @param {string} config.apiUrl - Your API URL (optional, defaults to production)
   */
  async init(config) {
    if (!config.apiKey) {
      console.error('[IntalksAICallRibbon] API key is required');
      return;
    }

    this.config = config;
    this.agentUserId = config.agentUserId || null;
    this.clientName = config.clientName || null;

    try {
      // Fetch Exotel credentials from your backend API
      const apiUrl = config.apiUrl || 'https://api.yourcompany.com';
      const response = await fetch(`${apiUrl}/api/ribbon/init`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          apiKey: config.apiKey,
          domain: window.location.hostname,
          agentUserId: config.agentUserId || null,
          clientName: config.clientName || null
        })
      });

      if (!response.ok) {
        throw new Error(`API request failed: ${response.statusText}`);
      }

      this.credentials = await response.json();
      console.log('[IntalksAICallRibbon] Credentials loaded successfully');

      // Create or get container
      this.container = document.getElementById('intalksai-call-ribbon-container');
      if (!this.container) {
        this.container = document.createElement('div');
        this.container.id = 'intalksai-call-ribbon-container';
        document.body.appendChild(this.container);
      }

      // Render the ribbon
      this.render();

      // Call ready callback
      if (config.onReady) {
        config.onReady();
      }

    } catch (error) {
      console.error('[IntalksAICallRibbon] Initialization failed:', error);
      
      // Create or get container for error display
      this.container = document.getElementById('intalksai-call-ribbon-container');
      if (!this.container) {
        this.container = document.createElement('div');
        this.container.id = 'intalksai-call-ribbon-container';
        document.body.appendChild(this.container);
      }

      // Render error state
      this.render();

      // Call ready callback if provided
      if (config.onReady) {
        config.onReady();
      }
    }
  }

  /**
   * Update customer data
   * @param {Object} customerData - Customer information
   * @param {string} customerData.phoneNumber - Customer's phone number
   * @param {string} customerData.name - Customer's name
   * @param {string} customerData.email - Customer's email
   * @param {string} customerData.customerId - Your CRM's customer ID
   */
  setCustomer(customerData) {
    this.customerData = customerData;
    this.render();
  }

  /**
   * Update ribbon position
   * @param {string} position - 'top', 'bottom', or 'floating'
   */
  setPosition(position) {
    if (this.config) {
      this.config.position = position;
      this.render();
    }
  }

  /**
   * Show or hide the ribbon
   * @param {boolean} visible - Show (true) or hide (false)
   */
  setVisible(visible) {
    if (this.container) {
      this.container.style.display = visible ? 'block' : 'none';
    }
  }

  /**
   * Minimize or expand the ribbon
   * @param {boolean} minimized - Minimized (true) or expanded (false)
   */
  setMinimized(minimized) {
    if (this.config) {
      this.config.minimized = minimized;
      this.render();
    }
  }

  /**
   * Make a call programmatically
   * @param {string} phoneNumber - Phone number to dial
   */
  makeCall(phoneNumber) {
    // This will be handled by the ribbon component
    // We can add a ref or event system if needed
    console.log('[IntalksAICallRibbon] Making call to:', phoneNumber);
  }

  /**
   * Render the ribbon component
   */
  render() {
    if (!this.container) {
      return;
    }
    
    // Validate credentials
    if (!this.credentials || !this.credentials.exotelToken || !this.credentials.userId) {
      console.error('[IntalksAICallRibbon] Missing credentials');
      this.container.innerHTML = '<div style="padding: 10px; background: #fee; border: 1px solid #fcc; border-radius: 4px; color: #c00;">Exotel credentials required</div>';
      return;
    }

    // Wrap callback to add logging
    const wrappedCallEvent = (event, data) => {
      // Log to your backend API
      this.logCallEvent(event, data);

      // Call client's callback
      if (this.config.onCallEvent) {
        this.config.onCallEvent(event, data);
      }
    };

    // Create or update root
    if (!this.root) {
      this.root = ReactDOM.createRoot(this.container);
    }

    this.root.render(
      React.createElement(CallControlRibbon, {
        config: {
          accessToken: this.credentials.exotelToken,
          userId: this.credentials.userId
        },
        customerData: this.customerData,
        position: this.config.position || 'bottom',
        minimized: this.config.minimized || false,
        onCallEvent: wrappedCallEvent,
        onReady: () => {
          console.log('[IntalksAICallRibbon] Ribbon is ready');
        }
      })
    );
  }

  /**
   * Log call event to backend
   */
  async logCallEvent(event, data) {
    try {
      const apiUrl = this.config.apiUrl || 'https://api.yourcompany.com';
      await fetch(`${apiUrl}/api/ribbon/log-call`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          apiKey: this.config.apiKey,
          event,
          data,
          timestamp: new Date().toISOString(),
          domain: window.location.hostname,
          agentUserId: this.agentUserId || null,
          clientName: this.clientName || null
        })
      });
    } catch (error) {
      console.error('[IntalksAICallRibbon] Failed to log call event:', error);
    }
  }

  /**
   * Show error message
   */
  showError(message) {
    if (!this.container) {
      this.container = document.createElement('div');
      this.container.id = 'intalksai-call-ribbon-container';
      document.body.appendChild(this.container);
    }

    this.container.innerHTML = `
      <div style="
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        background: #fee;
        color: #c33;
        padding: 15px 20px;
        text-align: center;
        font-family: sans-serif;
        z-index: 9999;
        border-top: 2px solid #c33;
      ">
        ⚠️ ${message}
      </div>
    `;
  }

  /**
   * Destroy the ribbon and clean up
   */
  destroy() {
    if (this.root) {
      this.root.unmount();
      this.root = null;
    }

    if (this.container && this.container.parentNode) {
      this.container.parentNode.removeChild(this.container);
      this.container = null;
    }

    this.config = null;
    this.credentials = null;
    this.customerData = null;
  }
}

// Create global instance
const ribbonInstance = new IntalksAICallRibbonWidget();

// Expose global API - Support both old and new names for compatibility
window.IntalksAICallRibbon = {
  /**
   * Initialize the ribbon
   */
  init: (config) => ribbonInstance.init(config),

  /**
   * Set customer data
   */
  setCustomer: (customerData) => ribbonInstance.setCustomer(customerData),

  /**
   * Change ribbon position
   */
  setPosition: (position) => ribbonInstance.setPosition(position),

  /**
   * Show or hide ribbon
   */
  setVisible: (visible) => ribbonInstance.setVisible(visible),

  /**
   * Minimize or expand ribbon
   */
  setMinimized: (minimized) => ribbonInstance.setMinimized(minimized),

  /**
   * Make a call
   */
  makeCall: (phoneNumber) => ribbonInstance.makeCall(phoneNumber),

  /**
   * Destroy ribbon
   */
  destroy: () => ribbonInstance.destroy(),

  /**
   * Get version
   */
  version: '1.0.0'
};

// Backward compatibility - alias to old name
window.ExotelCallRibbon = window.IntalksAICallRibbon;

// AMD/UMD support
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return window.IntalksAICallRibbon;
  });
}

// CommonJS support
if (typeof module === 'object' && module.exports) {
  module.exports = window.IntalksAICallRibbon;
}

  console.log('[IntalksAI Call Ribbon] Widget loaded v' + window.IntalksAICallRibbon.version);
