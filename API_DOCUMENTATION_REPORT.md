# Captain shellafood Delivery Driver App - API Documentation Report

## Project Overview
- **App Name**: منفذي الخدمات (Service Providers)
- **App Version**: 2.8
- **Current Base URL**: `https://shellafood_deliveryfood.net`
- **Platform**: Flutter/Dart (Mobile: Android & iOS, Web support)
- **Authentication**: Bearer Token (JWT)

---

## API Configuration

### Base URL
```
https://shellafood_deliveryfood.net
```

### Required Headers
All API requests must include:
```
Content-Type: application/json; charset=UTF-8
X-localization: en (or ar) // Language code
Authorization: Bearer {token} // For authenticated requests
```

### HTTP Methods Used
- GET: Retrieve data
- POST: Create/Submit data
- PUT: Update data (implemented as POST with `_method: "put"` field)
- DELETE: Remove data

### Timeout
- **30 seconds** for all requests

---

## API Endpoints

### 1. Configuration APIs

#### 1.1 Get Configuration
- **Endpoint**: `/api/v1/config`
- **Method**: GET
- **Auth**: Not required
- **Purpose**: Get app configuration settings
- **Response**: Configuration data including zones, vehicles, etc.

---

### 2. Authentication APIs

#### 2.1 Login
- **Endpoint**: `/api/v1/auth/delivery-man/login`
- **Method**: POST
- **Auth**: Not required
- **Request Body**:
```json
{
  "phone": "string",
  "password": "string"
}
```
- **Response**:
```json
{
  "token": "jwt_token_string",
  "topic": "zone_topic_string"
}
```

#### 2.2 Register Delivery Man
- **Endpoint**: `/api/v1/auth/delivery-man/store`
- **Method**: POST (Multipart)
- **Auth**: Not required
- **Request Body** (Form Data + Files):
```
f_name: string
l_name: string
phone: string
email: string
password: string
identity_type: string
identity_number: string
earning: string
zone_id: string
vehicle_id: string
image: File (profile image)
identity_images: File[] (multiple identity images)
```
- **Response**: 200 status on success

#### 2.3 Forgot Password
- **Endpoint**: `/api/v1/auth/delivery-man/forgot-password`
- **Method**: POST
- **Auth**: Not required
- **Request Body**:
```json
{
  "phone": "string"
}
```

#### 2.4 Verify Token (Forgot Password)
- **Endpoint**: `/api/v1/auth/delivery-man/verify-token`
- **Method**: POST
- **Auth**: Not required
- **Request Body**:
```json
{
  "phone": "string",
  "reset_token": "string"
}
```

#### 2.5 Reset Password
- **Endpoint**: `/api/v1/auth/delivery-man/reset-password`
- **Method**: POST (with `_method: "put"`)
- **Auth**: Not required
- **Request Body**:
```json
{
  "_method": "put",
  "phone": "string",
  "reset_token": "string",
  "password": "string",
  "confirm_password": "string"
}
```

---

### 3. Profile APIs

#### 3.1 Get Profile
- **Endpoint**: `/api/v1/delivery-man/profile?token={token}`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: token

#### 3.2 Update Profile
- **Endpoint**: `/api/v1/delivery-man/update-profile`
- **Method**: POST (Multipart)
- **Auth**: Required
- **Request Body** (Form Data + File):
```
_method: "put"
token: string
f_name: string
l_name: string
email: string
image: File (optional)
```
- **Note**: Password update can be added via `password` field in same endpoint

#### 3.3 Update Active Status
- **Endpoint**: `/api/v1/delivery-man/update-active-status`
- **Method**: POST
- **Auth**: Required
- **Request Body**:
```json
{
  "token": "string"
}
```

#### 3.4 Remove Account
- **Endpoint**: `/api/v1/delivery-man/remove-account?token={token}`
- **Method**: DELETE
- **Auth**: Required
- **Query Parameters**: token

---

### 4. Order APIs

#### 4.1 Get Current Orders
- **Endpoint**: `/api/v1/delivery-man/current-orders?token={token}`
- **Method**: GET
- **Auth**: Required
- **Purpose**: Get all pending/active orders assigned to delivery man
- **Response**: Array of orders

#### 4.2 Get Latest Orders
- **Endpoint**: `/api/v1/delivery-man/latest-orders?token={token}`
- **Method**: GET
- **Auth**: Required
- **Purpose**: Get newly available orders for delivery man
- **Response**: Array of orders

#### 4.3 Get All Orders (Pagination)
- **Endpoint**: `/api/v1/delivery-man/all-orders?token={token}&offset={offset}&limit=10`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: 
  - token
  - offset (pagination offset)
  - limit (default: 10)
- **Purpose**: Get completed order history with pagination
- **Response**: Paginated order list

#### 4.4 Get Specific Order
- **Endpoint**: `/api/v1/delivery-man/order?token={token}&order_id={id}`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: token, order_id
- **Purpose**: Get details of a specific order

#### 4.5 Get Order Details
- **Endpoint**: `/api/v1/delivery-man/order-details?token={token}&order_id={id}`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: token, order_id
- **Purpose**: Get detailed order information including items

#### 4.6 Accept Order
- **Endpoint**: `/api/v1/delivery-man/accept-order`
- **Method**: POST (with `_method: "put"`)
- **Auth**: Required
- **Request Body**:
```json
{
  "_method": "put",
  "token": "string",
  "order_id": integer
}
```

#### 4.7 Update Order Status
- **Endpoint**: `/api/v1/delivery-man/update-order-status`
- **Method**: POST (Multipart)
- **Auth**: Required
- **Request Body** (Form Data + Files):
```
_method: "put"
token: string
order_id: integer
status: string (pending, confirmed, accepted, processing, handover, picked_up, delivered, canceled, failed, refunded)
otp: string (for delivered status)
reason: string (optional, for canceled status)
proof_of_collection: File (optional)
proof_of_delivery: File (optional)
```
- **Status Values**: pending, confirmed, accepted, processing, handover, picked_up, delivered, canceled, failed, refunded

#### 4.8 Get Cancellation Reasons
- **Endpoint**: `/api/v1/customer/order/cancellation-reasons?offset=1&limit=30&type=deliveryman`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: offset, limit, type
- **Purpose**: Get list of cancellation reasons for orders

#### 4.9 Set Price Service
- **Endpoint**: `/api/v1/delivery-man/request`
- **Method**: POST
- **Auth**: Required
- **Request Body**:
```json
{
  "token": "string",
  "price": double,
  "order_id": integer,
  "delivery_man_id": integer
}
```
- **Purpose**: Submit a custom pricing request for an order

#### 4.10 Update Payment Status
- **Endpoint**: `/api/v1/delivery-man/update-payment-status`
- **Method**: POST
- **Auth**: Required
- **Request Body**:
```json
{
  "token": "string",
  "order_id": integer,
  "payment_status": string
}
```

---

### 5. Location & Tracking APIs

#### 5.1 Record Location Data
- **Endpoint**: `/api/v1/delivery-man/record-location-data`
- **Method**: POST
- **Auth**: Required
- **Request Body**:
```json
{
  "token": "string",
  "latitude": float,
  "longitude": float,
  "zone_id": integer,
  "heading": float (optional)
}
```
- **Frequency**: Should be called frequently to track delivery man location
- **Alternative**: Uses WebSocket for real-time tracking (see WebSocket section)

#### 5.2 WebSocket Live Location
- **Endpoint**: `ws://{websocket_uri}:{port}/delivery-man/live-location?appKey={key}`
- **Method**: WebSocket
- **Auth**: Query parameter `appKey`
- **Payload**:
```json
{
  "token": "string",
  "latitude": float,
  "longitude": float,
  "zone_id": integer,
  "heading": float
}
```
- **Purpose**: Real-time location streaming

---

### 6. Notification APIs

#### 6.1 Get Notifications
- **Endpoint**: `/api/v1/delivery-man/notifications?token={token}`
- **Method**: GET
- **Auth**: Required
- **Response**: Array of notifications with structure:
```json
{
  "data": {
    "title": "string",
    "description": "string",
    "image_full_url": "string",
    "notification_type": "string"
  }
}
```

#### 6.2 Send Delivered Order Notification (OTP)
- **Endpoint**: `/api/v1/delivery-man/send-order-otp`
- **Method**: POST (with `_method: "put"`)
- **Auth**: Required
- **Request Body**:
```json
{
  "_method": "put",
  "token": "string",
  "order_id": integer
}
```
- **Purpose**: Send OTP notification to customer for order delivery verification

#### 6.3 Update FCM Token
- **Endpoint**: `/api/v1/delivery-man/update-fcm-token`
- **Method**: POST (with `_method: "put"`)
- **Auth**: Required
- **Request Body**:
```json
{
  "_method": "put",
  "token": "string",
  "fcm_token": "string"
}
```
- **Purpose**: Update Firebase Cloud Messaging token for push notifications

---

### 7. Chat APIs

#### 7.1 Get Conversation List
- **Endpoint**: `/api/v1/delivery-man/message/list?token={token}&offset={offset}&limit=10`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: token, offset, limit
- **Purpose**: Get list of conversations

#### 7.2 Search Conversations
- **Endpoint**: `/api/v1/delivery-man/message/search-list?name={name}&token={token}&limit=20&offset=1`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: name, token, limit, offset
- **Purpose**: Search conversations by name

#### 7.3 Get Messages
- **Endpoint**: `/api/v1/delivery-man/message/details?{conversation_id or user_id or vendor_id}={id}&token={token}&offset={offset}&limit=10`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: 
  - conversation_id OR user_id OR vendor_id (depending on user type)
  - token, offset, limit
- **Purpose**: Get messages for a conversation

#### 7.4 Send Message
- **Endpoint**: `/api/v1/delivery-man/message/send`
- **Method**: POST (Multipart)
- **Auth**: Required
- **Request Body** (Form Data + Files):
```
message: string
receiver_type: string (user, customer, vendor)
conversation_id: integer (if existing conversation)
receiver_id: integer (if new conversation)
token: string
offset: string
limit: string
file: File (optional attachments)
```

---

### 8. Financial/Wallet APIs

#### 8.1 Get Wallet Payment List
- **Endpoint**: `/api/v1/delivery-man/wallet-payment-list?token={token}`
- **Method**: GET
- **Auth**: Required
- **Purpose**: Get cash in hand transaction history

#### 8.2 Make Collected Cash Payment
- **Endpoint**: `/api/v1/delivery-man/make-collected-cash-payment`
- **Method**: POST
- **Auth**: Required
- **Request Body**:
```json
{
  "amount": double,
  "payment_gateway": "string",
  "callback": "string",
  "token": "string"
}
```
- **Response**: 
```json
{
  "redirect_link": "string"
}
```
- **Purpose**: Initiate payment gateway flow for depositing collected cash

#### 8.3 Get Wallet Provided Earning List
- **Endpoint**: `/api/v1/delivery-man/wallet-provided-earning-list?token={token}`
- **Method**: GET
- **Auth**: Required
- **Purpose**: Get list of earnings provided from wallet

#### 8.4 Make Wallet Adjustment
- **Endpoint**: `/api/v1/delivery-man/make-wallet-adjustment`
- **Method**: POST
- **Auth**: Required
- **Request Body**:
```json
{
  "token": "string"
}
```
- **Purpose**: Adjust wallet balance

---

### 9. Disbursement APIs

#### 9.1 Get Withdraw Method List
- **Endpoint**: `/api/v1/delivery-man/get-withdraw-method-list?token={token}`
- **Method**: GET
- **Auth**: Required
- **Purpose**: Get available withdrawal methods

#### 9.2 Add Withdraw Method
- **Endpoint**: `/api/v1/delivery-man/withdraw-method/store?token={token}`
- **Method**: POST
- **Auth**: Required
- **Request Body**:
```json
{
  // withdrawal method fields
}
```

#### 9.3 Get Disbursement Method List
- **Endpoint**: `/api/v1/delivery-man/withdraw-method/list?limit=10&offset=1&token={token}`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: limit, offset, token
- **Purpose**: Get list of saved withdrawal methods

#### 9.4 Make Default Disbursement Method
- **Endpoint**: `/api/v1/delivery-man/withdraw-method/make-default?token={token}`
- **Method**: POST
- **Auth**: Required
- **Request Body**: Method ID or identifier

#### 9.5 Delete Disbursement Method
- **Endpoint**: `/api/v1/delivery-man/withdraw-method/delete?token={token}`
- **Method**: POST
- **Auth**: Required
- **Request Body**:
```json
{
  "_method": "delete",
  "id": integer
}
```

#### 9.6 Get Disbursement Report
- **Endpoint**: `/api/v1/delivery-man/get-disbursement-report?limit=10&offset={offset}&token={token}`
- **Method**: GET
- **Auth**: Required
- **Query Parameters**: limit, offset, token
- **Purpose**: Get withdrawal transaction history

---

### 10. Static Content APIs

#### 10.1 Get Privacy Policy
- **Endpoint**: `/privacy-policy`
- **Method**: GET
- **Auth**: Not required
- **Headers**: 
```
Content-Type: application/json; charset=UTF-8
Accept: application/json
moduleId: ""
X-localization: en or ar
```
- **Response**: HTML content

#### 10.2 Get Terms and Conditions
- **Endpoint**: `/terms-and-conditions`
- **Method**: GET
- **Auth**: Not required
- **Headers**: Same as privacy policy
- **Response**: HTML content

#### 10.3 Get About Us
- **Endpoint**: `/about-us`
- **Method**: GET
- **Auth**: Not required
- **Response**: HTML content

---

### 11. Zone & Vehicle APIs

#### 11.1 Get Zone List
- **Endpoint**: `/api/v1/zone/list`
- **Method**: GET
- **Auth**: Not required
- **Purpose**: Get available delivery zones

#### 11.2 Get Zone by ID
- **Endpoint**: `/api/v1/config/get-zone-id`
- **Method**: GET
- **Auth**: Not required
- **Purpose**: Get zone information by ID

#### 11.3 Get Vehicles List
- **Endpoint**: `/api/v1/get-vehicles`
- **Method**: GET
- **Auth**: Not required
- **Purpose**: Get list of available vehicle types for registration

---

## Common Response Structures

### Success Response
```json
{
  "message": "success message",
  "data": { ... }
}
```

### Error Response
```json
{
  "errors": [
    {
      "code": "error_code",
      "message": "error message"
    }
  ]
}
```

### Pagination Response
```json
{
  "data": [ ... ],
  "total_size": integer,
  "limit": integer,
  "offset": integer
}
```

---

## Important Notes for Backend Team

### 1. Authentication
- Bearer token authentication is required for most endpoints
- Token is sent in header: `Authorization: Bearer {token}`
- Token is also sometimes sent as query parameter `token`

### 2. Multipart Form Data
These endpoints support file uploads:
- Register Delivery Man
- Update Profile
- Update Order Status
- Send Message (chat with file attachments)

### 3. Status Flow for Orders
```
pending → confirmed → accepted → processing → handover → picked_up → delivered
```
Alternative flows: `canceled`, `failed`, `refunded`

### 4. Pagination
Most list endpoints support pagination:
- Parameters: `offset` (default: 1) and `limit` (default: 10)
- Response includes `total_size`, `offset`, `limit`

### 5. File Uploads
- Supported formats: Images (JPG, PNG)
- Max file size: Not specified in app (should be reasonable)
- Fields for file uploads: `image`, `identity_images[]`, `proof_of_collection`, `proof_of_delivery`, `file`

### 6. WebSocket Requirements
- WebSocket server for real-time location tracking
- Configuration comes from `/api/v1/config` endpoint
- Required fields: `webSocketUri`, `webSocketPort`, `webSocketKey`

### 7. Firebase Integration
- FCM tokens for push notifications
- Device tokens need to be stored and updated
- Notification topics for broadcasting

### 8. Language Support
- Primary: English (en), Arabic (ar)
- Headers include `X-localization` for language-specific content

### 9. Error Handling
- Standard HTTP status codes
- Error messages should be in the language specified by `X-localization` header
- 200 status code expected for success

### 10. Phone Number Validation
- Phone numbers should be validated
- Country code support

---

## Migration Requirements

When updating the backend:

1. **URL Structure**: Ensure all endpoints match exactly as specified
2. **Parameter Names**: Use snake_case (e.g., `f_name`, `l_name`, `order_id`)
3. **HTTP Methods**: POST with `_method: "put"` for updates (following Laravel conventions)
4. **Multipart**: Support file uploads in designated endpoints
5. **Response Format**: Maintain consistent JSON structure
6. **Timezone**: Handle dates in ISO 8601 format with timezone info
7. **Pagination**: Implement offset-based pagination
8. **WebSocket**: Real-time location streaming capability

---

## Testing Recommendations

1. Test all authentication flows (login, register, forgot password)
2. Verify file upload functionality
3. Test pagination on list endpoints
4. Validate multipart form data
5. Test real-time location tracking
6. Verify notification delivery
7. Test chat functionality with file attachments
8. Validate order status transitions
9. Test payment gateway integration
10. Verify language localization

---

## Contact for Questions

For any clarification needed on these APIs, please refer to this document or contact the frontend development team.


