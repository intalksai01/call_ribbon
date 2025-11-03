# Exotel WebRTC Firewall Whitelist Requirements

Based on [Exotel Support Documentation](https://support.exotel.com/support/solutions/articles/3000120566-ip-pstn-intermix-customer-onboarding-and-webrtc-sdk-integration), the following firewall rules must be configured for successful WebRTC calling.

## Required Firewall Whitelist Configuration

**Whitelist the following ports, domains and IP addresses in all networks' firewall where the WebSDK will be running:**

| Type | Port/Endpoint | Description |
|------|---------------|-------------|
| **HTTP** | tcp/80 | Standard HTTP traffic |
| **HTTPS / TLS** | tcp/443 | Secure web and SIP traffic |
| **SIP Gateway** | `voip.in1.exotel.com` | Exotel SIP WebRTC gateway |
| **Media Server Ports** | udp/10000 - 40000 | RTP media streams for audio |
| **Media Server IP - Bangalore, KA** | `61.246.82.75`, `14.194.10.247` | Media servers in Bangalore |
| **Media Server IP - Mumbai, MH** | `182.76.143.61`, `122.15.8.18` | Media servers in Mumbai |
| **HTTPS for API** | `integrationscore.mum1.exotel.com` | Exotel management API |

## Current Deployment

### Widget Deployment (CloudFront + S3)
- **S3 Website URL:** `http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com`
- **CloudFront URL:** `https://d2t5fsybshqnye.cloudfront.net`
- **Region:** Mumbai (ap-south-1)

### API Deployment (Elastic Beanstalk)
- **URL:** `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com`
- **Region:** Mumbai (ap-south-1)

## Firewall Configuration Locations

### For Corporate Networks
1. **Corporate Firewall:** Contact IT admin to whitelist above ports and IPs
2. **Proxy Server:** Configure proxy to allow WebRTC traffic
3. **VPN:** Ensure VPN allows media ports (udp/10000-40000)

### For Cloud Infrastructure (AWS)
**Elastic Beanstalk Security Group:**
- Port 80 (HTTP) from 0.0.0.0/0
- Port 443 (HTTPS) from 0.0.0.0/0
- Outbound: Allow all (for WebRTC)

**CloudFront/S3:**
- Already configured for public access
- No additional firewall rules needed

### For End User Devices
**Browser-based WebRTC:**
- Most users: No action needed (browser handles it)
- Corporate users behind firewalls: Contact IT admin

**If users see connection issues:**
1. Check browser console for WebRTC errors
2. Verify firewall allows udp/10000-40000
3. Test with `https://webrtc.github.io/samples/src/content/getusermedia/getdisplaymedia/`

## Testing Firewall Configuration

### Test 1: SIP Gateway Connectivity
```bash
curl -v https://voip.in1.exotel.com
# Should return 200 or SIP error (not connection timeout)
```

### Test 2: API Connectivity
```bash
curl -v https://integrationscore.mum1.exotel.com
# Should return 200 or API error (not connection timeout)
```

### Test 3: Media Server Connectivity (from Mumbai)
```bash
# Test if media servers are reachable
ping 182.76.143.61
ping 122.15.8.18

# Test UDP port range (requires specialized tool)
# Most firewalls block ICMP, so UDP test is more reliable
```

### Test 4: Browser WebRTC
1. Open browser developer console
2. Go to Network tab
3. Navigate to widget URL
4. Make a test call
5. Check for blocked requests to:
   - `voip.in1.exotel.com`
   - Media server IPs on udp ports

## Troubleshooting

### Issue: "Failed to connect to Exotel"
**Solution:** Firewall blocking tcp/443 to voip.in1.exotel.com

### Issue: "Call connects but no audio"
**Solution:** Firewall blocking udp/10000-40000 to media servers

### Issue: "Registration successful but calls fail"
**Solution:** Media server IPs not whitelisted

### Issue: "Works on WiFi but not on corporate network"
**Solution:** Corporate firewall needs configuration

### Issue: "Call can not be made because of TRAI NDNC regulations" (Error 403)
**Solution:** This is NOT a firewall issue. The phone number is blocked by TRAI DND registry.
- **Test numbers are blocked by default** in Exotel
- Use real allowed phone numbers for testing
- Contact Exotel support to whitelist test numbers if needed
- See TRAI DNC registry: https://ndnc.gov.in/

## Exotel Support
- **WhatsApp:** 08088919888
- **Dashboard Chat:** Available on Exotel dashboard
- **Support Article:** https://support.exotel.com/support/solutions/articles/3000120566-ip-pstn-intermix-customer-onboarding-and-webrtc-sdk-integration

---

**Last Updated:** November 2, 2025  
**Reference:** Exotel Support Documentation Step 6 - Firewall Whitelist

