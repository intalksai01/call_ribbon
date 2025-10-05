import React from 'react';
import ReactDOM from 'react-dom/client';
import './CallControlRibbon.css';
import CallControlRibbon from './CallControlRibbon';

// Demo page for testing
function DemoApp() {
  const [customer, setCustomer] = React.useState(null);

  const exotelConfig = {
    accessToken: process.env.REACT_APP_EXOTEL_ACCESS_TOKEN || 'demo-token',
    userId: process.env.REACT_APP_EXOTEL_USER_ID || 'demo-user'
  };

  const demoCustomers = [
    { id: '1', name: 'John Doe', phoneNumber: '+919876543210' },
    { id: '2', name: 'Jane Smith', phoneNumber: '+918765432109' },
    { id: '3', name: 'Bob Johnson', phoneNumber: '+917654321098' }
  ];

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>Call Control Ribbon - Demo</h1>
      <p>Select a customer to see the ribbon in action:</p>
      
      <div style={{ display: 'flex', gap: '10px', marginBottom: '100px' }}>
        {demoCustomers.map(c => (
          <button
            key={c.id}
            onClick={() => setCustomer(c)}
            style={{
              padding: '10px 20px',
              backgroundColor: customer?.id === c.id ? '#667eea' : '#e5e7eb',
              color: customer?.id === c.id ? 'white' : 'black',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer'
            }}
          >
            {c.name}
          </button>
        ))}
      </div>

      <CallControlRibbon
        config={exotelConfig}
        customerData={customer}
        position="bottom"
        onCallEvent={(event, data) => {
          console.log('Call event:', event, data);
        }}
      />
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<DemoApp />);

