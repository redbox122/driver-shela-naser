# 📱 All Push Notifications Sent to Three Apps - Translation List

**Purpose:** Complete list of all notifications sent to Customer App, Vendor/Employee App, and Delivery Man App for translation setup.

**Date:** 2025-01-14

---

## 🎯 Notification Apps Overview

1. **Customer App** - Notifications sent to customers
2. **Vendor/Employee App** - Notifications sent to store owners and employees
3. **Delivery Man App** - Notifications sent to delivery personnel

---

## 📋 Notification List by App

### 1. CUSTOMER APP NOTIFICATIONS

#### 1.1 Order Notifications

| Notification Type | Title Key | Description | Status | When Sent |
|------------------|-----------|-------------|--------|-----------|
| **New Order Created** | `Order_Notification` | Dynamic message from `order_status_update_message()` based on status | ✅ Active | When order status changes |
| **Order Pending** | `Order_Notification` | `order_pending_message` (from NotificationMessage table) | ✅ Active | Order status = `pending` |
| **Order Confirmed** | `Order_Notification` | `order_confirmation_msg` (from NotificationMessage table) | ✅ Active | Order status = `confirmed` |
| **Order Processing** | `Order_Notification` | `order_processing_message` (from NotificationMessage table) | ✅ Active | Order status = `processing` |
| **Order Picked Up** | `Order_Notification` | `out_for_delivery_message` (from NotificationMessage table) | ✅ Active | Order status = `picked_up` |
| **Order Handover** | `Order_Notification` | `order_handover_message` (from NotificationMessage table) | ✅ Active | Order status = `handover` |
| **Order Delivered** | `Order_Notification` | `order_delivered_message` (from NotificationMessage table) | ✅ Active | Order status = `delivered` |
| **Order Delivered (by DM)** | `Order_Notification` | `delivery_boy_delivered_message` (from NotificationMessage table) | ✅ Active | Order status = `delivered` with delivery man |
| **Order Accepted (by DM)** | `Order_Notification` | `delivery_boy_assign_message` (from NotificationMessage table) | ✅ Active | Order status = `accepted` |
| **Order Canceled** | `Order_Notification` | `order_cancled_message` (from NotificationMessage table) | ✅ Active | Order status = `canceled` |
| **Order Refunded** | `Order_Notification` | `order_refunded_message` (from NotificationMessage table) | ✅ Active | Order status = `refunded` |
| **Refund Request Canceled** | `Order_Notification` | `refund_request_canceled` (from NotificationMessage table) | ✅ Active | Refund request canceled |
| **Offline Order Verified** | `Order_Notification` | `offline_order_accept_message` (from NotificationMessage table) | ✅ Active | Offline order verified |
| **Offline Order Denied** | `Order_Notification` | `offline_order_deny_message` (from NotificationMessage table) | ✅ Active | Offline order denied |

**Note:** Customer notification messages are dynamic and use variables (from database templates):
- `{userName}` - Customer name (replaced with `user_name` in code)
- `{orderId}` - Order ID (replaced with `order_id` in code)
- `{storeName}` - Store name (replaced with `store_name` in code)
- `{delivery_man_name}` - Delivery man name (if applicable, replaced in code)

#### 1.2 Trip Notifications (Rental Module)

| Notification Type | Title Key | Description | Status | When Sent |
|------------------|-----------|-------------|--------|-----------|
| **Trip Payment Notification** | `Trip_Notification_payment` | Dynamic: "Your transaction has been completed" OR "Your payment has not been received yet" | ✅ Active | When trip payment status changes |

#### 1.3 Message Notifications

| Notification Type | Title Key | Description | Status | When Sent |
|------------------|-----------|-------------|--------|-----------|
| **New Message** | `messages.message` | `messages.message_description` | ✅ Active | When customer receives message from vendor/delivery man |

#### 1.4 App Update Notifications

| Notification Type | Title Key | Description | Status | When Sent |
|------------------|-----------|-------------|--------|-----------|
| **App Update Required** | Custom (Admin sets) | Custom message (Admin sets) | ✅ Active | Admin sends update notification via API |

---

### 2. VENDOR/EMPLOYEE APP NOTIFICATIONS

#### 2.1 Order Notifications

| Notification Type | Title Key | Description | Status | When Sent |
|------------------|-----------|-------------|--------|-----------|
| **New Order Created** | `Order_Notification` | `messages.new_order_push_description` | ✅ Active | When new order is created (pending or confirmed) |
| **Order Status Update** | `Order_Notification` | Dynamic message from `order_status_update_message()` | ✅ Active | When order status changes (especially `picked_up`) |

**Note:** Same notification is sent to:
- Vendor owner (via `vendors.firebase_token`)
- All store employees (via `vendor_employees.firebase_token`)
- Web subscriptions (via topic `store_panel_{store_id}_message`)

#### 2.2 Message Notifications

| Notification Type | Title Key | Description | Status | When Sent |
|------------------|-----------|-------------|--------|-----------|
| **New Message** | `messages.message` | `messages.message_description` | ✅ Active | When vendor receives message from customer |

---

### 3. DELIVERY MAN APP NOTIFICATIONS

#### 3.1 Order Notifications

| Notification Type | Title Key | Description | Status | When Sent |
|------------------|-----------|-------------|--------|-----------|
| **New Delivery Order Available** | `Order_Notification` | `messages.new_order_push_description` | ✅ Active | When delivery order is created (pending or confirmed) |
| **New Parcel Order Available** | `Order_Notification` | `messages.new_order_push_description` | ✅ Active | When parcel order is created (pending or confirmed) |
| **Order Processing** | `Order_Notification` | `messages.Proceed_for_cooking` | ✅ Active | Order status = `processing` (if assigned) |
| **Order Ready for Delivery** | `Order_Notification` | `messages.ready_for_delivery` | ✅ Active | Order status = `handover` (if assigned) |
| **Order Accepted (by DM)** | `Order_Notification` | `delivery_boy_assign_message` (from NotificationMessage table) | ✅ Active | Order status = `accepted` |

**Note:** Delivery man notifications are sent via:
- Topic notifications: `restaurant_dm_{store_id}`, `delivery_man_{zone_id}_{vehicle_id}`, zone deliveryman topics
- Individual push (when assigned): `delivery_men.fcm_token`

#### 3.2 Message Notifications

| Notification Type | Title Key | Description | Status | When Sent |
|------------------|-----------|-------------|--------|-----------|
| **New Message** | `messages.message` | `messages.message_description` | ✅ Active | When delivery man receives message from customer |

---

## 🔑 Translation Keys Reference

### Main Title Keys (Always Used)

| Key | Default Value | Used In |
|-----|---------------|---------|
| `Order_Notification` | "Order Notification" | All apps - order related |
| `Trip_Notification_payment` | "Trip Notification payment" | Customer app - trip payments |
| `messages.message` | "Message" | All apps - chat messages |

### Description Keys (Static)

| Key | Default Value | Used In |
|-----|---------------|---------|
| `messages.new_order_push_description` | "New order push description" | Vendor/Employee/Delivery Man - new orders |
| `messages.message_description` | "Message Description" | All apps - chat messages |
| `messages.Proceed_for_cooking` | "Proceed for processing" | Delivery Man - order processing |
| `messages.ready_for_delivery` | "Ready for delivery" | Delivery Man - order handover |

### Dynamic Messages (From Database - NotificationMessage Table)

These are stored in `notification_messages` table and can be customized per module:

| Key | Used For | Status |
|-----|----------|--------|
| `order_pending_message` | Order pending | ✅ |
| `order_confirmation_msg` | Order confirmed | ✅ |
| `order_processing_message` | Order processing | ✅ |
| `out_for_delivery_message` | Order picked up/out for delivery | ✅ |
| `order_handover_message` | Order handover | ✅ |
| `order_delivered_message` | Order delivered | ✅ |
| `delivery_boy_delivered_message` | Order delivered by delivery man | ✅ |
| `delivery_boy_assign_message` | Order accepted by delivery man | ✅ |
| `order_cancled_message` | Order canceled | ✅ |
| `order_refunded_message` | Order refunded | ✅ |
| `refund_request_canceled` | Refund request canceled | ✅ |
| `offline_order_accept_message` | Offline order verified | ✅ |
| `offline_order_deny_message` | Offline order denied | ✅ |

---

## 📊 Complete Notification Messages Database Table

**Source:** `notification_messages` table (queried from database)  
**Total Records:** 51 messages across 5 module types

### Module Type: **FOOD** 🍔

| ID | Key | Message Template | Variables Used |
|----|-----|------------------|----------------|
| 12 | `order_pending_message` | `{userName}, Your order {orderId} is successfully placed` | `{userName}`, `{orderId}` |
| 13 | `order_confirmation_msg` | `{userName}, Your order {orderId} is confirmed` | `{userName}`, `{orderId}` |
| 14 | `order_processing_message` | `{userName}, Your food is started for cooking by {storeName}` | `{userName}`, `{storeName}` |
| 15 | `order_handover_message` | `Delivery man is on the way. For this order {orderId}` | `{orderId}` |
| 16 | `order_refunded_message` | `Order {orderId} Refunded successfully` | `{orderId}` |
| 17 | `refund_request_canceled` | `Order {orderId} Refund request is canceled` | `{orderId}` |
| 18 | `out_for_delivery_message` | `{userName}, Your order {orderId} is ready for delivery` | `{userName}`, `{orderId}` |
| 19 | `order_delivered_message` | `Your order {orderId} is delivered` | `{orderId}` |
| 20 | `delivery_boy_assign_message` | `Your order {orderId} has been assigned to a delivery man` | `{orderId}` |
| 21 | `delivery_boy_delivered_message` | `Order {orderId} delivered successfully` | `{orderId}` |
| 22 | `order_cancled_message` | `Order {orderId} is canceled by your request` | `{orderId}` |

### Module Type: **GROCERY** 🛒

| ID | Key | Message Template | Variables Used |
|----|-----|------------------|----------------|
| 1 | `order_pending_message` | `{userName}, Your order {orderId} is successfully placed` | `{userName}`, `{orderId}` |
| 2 | `order_confirmation_msg` | `{userName}, Your order {orderId} is confirmed` | `{userName}`, `{orderId}` |
| 3 | `order_processing_message` | `{userName}, Your order is Processing by {storeName}` | `{userName}`, `{storeName}` |
| 4 | `order_handover_message` | `Delivery man is on the way. For this order {orderId}` | `{orderId}` |
| 5 | `order_refunded_message` | `Order {orderId} Refunded successfully` | `{orderId}` |
| 6 | `refund_request_canceled` | `Order {orderId} Refund request is canceled` | `{orderId}` |
| 7 | `out_for_delivery_message` | `{userName}, Your order {orderId} is ready for delivery` | `{userName}`, `{orderId}` |
| 8 | `order_delivered_message` | `Your order {orderId} is delivered` | `{orderId}` |
| 9 | `delivery_boy_assign_message` | `Your order {orderId} has been assigned to a delivery man` | `{orderId}` |
| 10 | `delivery_boy_delivered_message` | `Order {orderId} delivered successfully` | `{orderId}` |
| 11 | `order_cancled_message` | `Order {orderId} is canceled by your request` | `{orderId}` |

### Module Type: **PHARMACY** 💊

| ID | Key | Message Template | Variables Used |
|----|-----|------------------|----------------|
| 23 | `order_pending_message` | `{userName}, Your order {orderId} is successfully placed` | `{userName}`, `{orderId}` |
| 24 | `order_confirmation_msg` | `{userName}, Your order {orderId} is confirmed` | `{userName}`, `{orderId}` |
| 25 | `order_processing_message` | `{userName}, Your order is Processing by {storeName}` | `{userName}`, `{storeName}` |
| 26 | `order_handover_message` | `Delivery man is on the way. For this order {orderId}` | `{orderId}` |
| 27 | `order_refunded_message` | `Order {orderId} Refunded successfully` | `{orderId}` |
| 28 | `refund_request_canceled` | `Order {orderId} Refund request is canceled` | `{orderId}` |
| 29 | `out_for_delivery_message` | `{userName}, Your order {orderId} is ready for delivery` | `{userName}`, `{orderId}` |
| 30 | `order_delivered_message` | `Your order {orderId} is delivered` | `{orderId}` |
| 31 | `delivery_boy_assign_message` | `Your order {orderId} has been assigned to a delivery man` | `{orderId}` |
| 32 | `delivery_boy_delivered_message` | `Order {orderId} delivered successfully` | `{orderId}` |
| 33 | `order_cancled_message` | `Order {orderId} is canceled by your request` | `{orderId}` |

### Module Type: **ECOMMERCE** 🛍️

| ID | Key | Message Template | Variables Used |
|----|-----|------------------|----------------|
| 34 | `order_pending_message` | `{userName}, Your order {orderId} is successfully placed` | `{userName}`, `{orderId}` |
| 35 | `order_confirmation_msg` | `{userName}, Your order {orderId} is confirmed` | `{userName}`, `{orderId}` |
| 36 | `order_processing_message` | `{userName}, Your order is Processing by {storeName}` | `{userName}`, `{storeName}` |
| 37 | `order_handover_message` | `Delivery man is on the way. For this order {orderId}` | `{orderId}` |
| 38 | `order_refunded_message` | `Order {orderId} Refunded successfully` | `{orderId}` |
| 39 | `refund_request_canceled` | `Order {orderId} Refund request is canceled` | `{orderId}` |
| 40 | `out_for_delivery_message` | `{userName}, Your order {orderId} is ready for delivery` | `{userName}`, `{orderId}` |
| 41 | `order_delivered_message` | `Your order {orderId} is delivered` | `{orderId}` |
| 42 | `delivery_boy_assign_message` | `Your order {orderId} has been assigned to a delivery man` | `{orderId}` |
| 43 | `delivery_boy_delivered_message` | `Order {orderId} delivered successfully` | `{orderId}` |
| 44 | `order_cancled_message` | `Order {orderId} is canceled by your request` | `{orderId}` |

### Module Type: **PARCEL** 📦

| ID | Key | Message Template | Variables Used |
|----|-----|------------------|----------------|
| 45 | `order_pending_message` | `{userName}, Your parcel order is successfully placed` | `{userName}` |
| 46 | `order_confirmation_msg` | `Your order {orderId} is confirmed` | `{orderId}` |
| 47 | `out_for_delivery_message` | `Your parcel order {orderId} is ready for delivery` | `{orderId}` |
| 48 | `order_delivered_message` | `Your parcel id {orderId} is delivered` | `{orderId}` |
| 49 | `delivery_boy_assign_message` | `Your order {orderId} has been assigned to a delivery man` | `{orderId}` |
| 50 | `delivery_boy_delivered_message` | `parcel id {orderId} delivered successfully` | `{orderId}` |
| 51 | `order_cancled_message` | `Order is canceled by your request` | None |

**Note:** Parcel module has fewer message types (7 vs 11 for other modules).

### Variable Reference Guide

All notification messages use these variable placeholders (case-sensitive):

| Variable | Replaced With | Example |
|----------|---------------|---------|
| `{userName}` | Customer full name (`f_name + l_name`) | "John Doe" |
| `{orderId}` | Order ID number | "123" |
| `{storeName}` | Store name | "Pizza House" |
| `{delivery_man_name}` | Delivery man full name (if applicable) | "Mike Rider" |

**Important:** Translation teams must preserve these variable placeholders exactly as shown (including curly braces) when translating messages.

### Trip Messages (Rental Module)

| Key | Default Value | Used In |
|-----|---------------|---------|
| "Your transaction has been completed" | Hardcoded | Customer app - trip payment paid |
| "Your payment has not been received yet" | Hardcoded | Customer app - trip payment unpaid |

---

## 📝 Notification Data Structure

All notifications follow this structure:

```json
{
  "title": "Translation key or string",
  "description": "Translation key or dynamic message",
  "order_id": 123,
  "image": "",
  "type": "new_order|order_status|message|app_update|trip_status",
  "module_id": 1,
  "order_type": "delivery|take_away|parcel|trip",
  "zone_id": 1,
  "conversation_id": 123,
  "sender_type": "user|vendor|delivery_man"
}
```

---

## 🎨 Variable Replacement in Messages

Customer order status messages use these variables (as they appear in database templates):

**Database Template Variables (exact casing):**
- `{userName}` - Customer full name
- `{orderId}` - Order ID
- `{storeName}` - Store name

**Code Replacement:**
The `text_variable_data_format()` function replaces these with actual values:
- `{userName}` → `$user_name` parameter
- `{orderId}` → `$order_id` parameter  
- `{storeName}` → `$store_name` parameter
- `{delivery_man_name}` → `$delivery_man_name` parameter (added in code, not in all templates)

Example:
- Database Template: `"{userName}, Your order {orderId} is confirmed"`
- After Replacement: `"John Doe, Your order 123 is confirmed"`

---

## 📍 Code Locations

### Main Notification Function
- **File:** `app/CentralLogics/helpers.php`
- **Function:** `send_order_notification($order)` - Lines 2228-2458
- **Function:** `order_status_update_message($status, $module_type, $lang)` - Lines 2160-2230
- **Function:** `send_notifications_to_store_employees($store_id, $data)` - Lines 1907-1967
- **Function:** `sendTripPaymentNotificationCustomerMain($trip)` - Lines 5082-5110

### Notification Sending
- **File:** `app/CentralLogics/helpers.php`
- **Function:** `send_push_notif_to_device($fcm_token, $data, $click_action)` - Lines 1720-1795
- **Function:** `send_push_notif_to_topic($data, $topic, $notification_type, $click_action)` - Lines 1850-1895

### Message Notifications
- **File:** `app/Http/Controllers/Api/V1/ConversationController.php`
- **Function:** `send_message()` - Lines 148-242

### App Update Notifications
- **File:** `app/Http/Controllers/Api/V1/AppVersionController.php`
- **Function:** `sendUpdateNotification()` - Lines 138-187

---

## ✅ Action Items for Translation Teams

### Customer App Team:
1. Translate `Order_Notification` title key
2. Translate `Trip_Notification_payment` title key
3. Translate `messages.message` title key
4. Translate `messages.message_description` description key
5. Ensure dynamic order status messages support variable replacement
6. Translate hardcoded trip payment messages

### Vendor/Employee App Team:
1. Translate `Order_Notification` title key
2. Translate `messages.new_order_push_description` description key
3. Translate `messages.message` title key
4. Translate `messages.message_description` description key
5. Ensure dynamic order status messages support variable replacement

### Delivery Man App Team:
1. Translate `Order_Notification` title key
2. Translate `messages.new_order_push_description` description key
3. Translate `messages.Proceed_for_cooking` description key
4. Translate `messages.ready_for_delivery` description key
5. Translate `messages.message` title key
6. Translate `messages.message_description` description key
7. Ensure dynamic order status messages support variable replacement

---

## 📌 Important Notes

1. **Dynamic Messages:** Many notification messages are stored in the `notification_messages` database table and can be customized per module type (food, grocery, pharmacy, etc.). These should be managed through the admin panel.

2. **Variable Support:** Customer order status messages include variables like `{store_name}`, `{order_id}`, `{user_name}`, `{delivery_man_name}`. Translation teams must ensure these variables are preserved in translated strings.

3. **Multi-language:** The system supports multiple languages. Notification messages use the `translate()` function which respects user's language preference stored in `users.current_language_key` or defaults to 'en'.

4. **Module-specific:** Some messages are module-specific (food, grocery, pharmacy, etc.). The `order_status_update_message()` function uses `module_type` parameter to fetch correct messages.

5. **Topic Notifications:** Some notifications are sent via FCM topics (like `admin_message`, `store_panel_{store_id}_message`, `restaurant_dm_{store_id}`). These use the same notification structure.

---

## 🔍 Testing Recommendations

1. Test notifications in all three apps with different languages
2. Verify variable replacement works correctly in translated messages
3. Test all order status transitions to ensure messages display properly
4. Test message notifications between different user types
5. Verify app update notifications display correctly

---

**Document created by:** Aziz (24 years old developer 😎)  
**Last updated:** 2025-01-14

---

## 📝 Quick Summary for Translation Teams

### What You Need to Translate:

1. **Static Translation Keys** (in language files):
   - `Order_Notification` (title)
   - `Trip_Notification_payment` (title)
   - `messages.message` (title)
   - `messages.message_description` (description)
   - `messages.new_order_push_description` (description)
   - `messages.Proceed_for_cooking` (description)
   - `messages.ready_for_delivery` (description)

2. **Dynamic Messages from Database** (51 messages):
   - All messages from `notification_messages` table
   - Organized by module type: Food, Grocery, Pharmacy, Ecommerce, Parcel
   - Must preserve variable placeholders: `{userName}`, `{orderId}`, `{storeName}`, `{delivery_man_name}`

3. **Hardcoded Messages**:
   - Trip payment messages: "Your transaction has been completed" / "Your payment has not been received yet"
   - App update notifications (custom admin messages)

### Critical Translation Rules:

✅ **DO:**
- Preserve all variable placeholders exactly: `{userName}`, `{orderId}`, `{storeName}`
- Keep variable casing as shown (camelCase in templates)
- Translate message content around variables
- Test variable replacement after translation

❌ **DON'T:**
- Change variable names or casing
- Remove variable placeholders
- Translate variable names themselves
- Add extra spaces inside variable placeholders

### Database Messages Management:

All notification messages from `notification_messages` table can be:
- **Viewed/Edited:** Via Admin Panel → Business Settings → Notification Messages
- **Module-Specific:** Each module (food, grocery, pharmacy, etc.) has its own set
- **Multi-language:** Translations stored in `translations` table (morphMany relationship)
- **Status:** Can be enabled/disabled via `status` field (1 = active, 0 = inactive)

---

**Total Messages to Translate:**
- Static keys: ~7
- Database messages: 51 (per module type)
- Hardcoded: 2
- **Grand Total:** ~60 unique notification strings per language

