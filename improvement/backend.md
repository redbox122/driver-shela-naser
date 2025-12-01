# Flutter Delivery Man App - Current Implementation Questions

**Date:** November 28, 2025  
**Priority:** HIGH  
**Status:** Ready for Flutter Team Review

---

## 🎯 Purpose

This document contains:
1. **Backend Changes Summary** - What we changed on the backend
2. **20 Questions About Your Current Implementation** - To understand what you have now
3. **What You Need to Know** - Backend changes and their impact

---

## 📋 Executive Summary

### Backend Changes Made:

- **Delivery Man Replaces Vendor:** For modules 6, 7, 8, 9, delivery men replace vendor role (temporary solution)
- **Accept = Confirm:** When delivery man accepts order for modules 6/7/8/9, order status becomes `confirmed` (not `accepted`)
- **Store OTP Skipped:** Modules 6, 7, 8, 9 don't need store OTP (only customer OTP)
- **Menu/Facture Photo Upload:** Delivery men can upload order_proof photos before pickup (modules 6/7/8/9)
- **Module 9 Added:** Same behavior as modules 6, 7, 8

### What Stayed the Same:

- ✅ All APIs work exactly the same (same endpoints, same responses)
- ✅ Customer OTP still required for delivery
- ✅ Module 3 (HyperShella) behavior unchanged

---

## 🚀 Backend Changes Summary

### 1. Store OTP Skipped for Modules 6, 7, 8, 9

**What We Changed:**
- Delivery men can pick up orders from modules 6, 7, 8, 9 **without store OTP**
- Only customer OTP is required for delivery
- Module 3 (HyperShella) still requires store OTP (has vendor app)

**API Impact:**
- `PUT /api/v1/delivery-man/update-order-status` - Store OTP field is optional for modules 6/7/8/9
- You can send `status: "picked_up"` without `otp_store` for these modules
- For module 3, `otp_store` is still required

---

### 2. Delivery Man Replaces Vendor Role

**What We Changed:**
- For modules 6, 7, 8, 9: **Delivery men temporarily replace vendor role**
- When delivery man accepts order → Order becomes `confirmed` (replaces vendor confirmation step)
- Customer sees order waiting for confirmation → Delivery man accepts → Customer sees confirmed

**Flow:**
1. Customer creates order → Status: `pending` (customer sees "waiting for confirmation")
2. Delivery man receives notification
3. Delivery man accepts order → Status: `confirmed` (replaces vendor confirmation)
4. Customer sees order confirmed
5. Delivery man goes to store, pays, collects items
6. Delivery man uploads menu/facture photos
7. Delivery man picks up (no store OTP)
8. Delivery man delivers (customer OTP)

**API Impact:**
- `PUT /api/v1/delivery-man/accept-order` - For modules 6/7/8/9, sets status to `confirmed` (not `accepted`)
- Orders from modules 6, 7, 8, 9 start as `pending` status
- When delivery man accepts, order becomes `confirmed` immediately

---

### 3. Menu/Facture Photo Upload Before Pickup

**What We Changed:**
- Delivery men can upload `order_proof` (menu/facture photos) when order status is `confirmed`
- This happens before pickup (for modules 6, 7, 8, 9)
- Photos are uploaded via `update-order-status` API with status `confirmed`

**API Usage:**
```json
PUT /api/v1/delivery-man/update-order-status
{
  "status": "confirmed",
  "order_id": 12345,
  "order_proof": [file1, file2, ...]  // Upload menu/facture photos
}
```

### 4. Module 9 Added

**What We Changed:**
- Module 9 (Drinks/Desserts) works same as modules 6, 7, 8
- No store OTP needed
- Delivery man replaces vendor role

---

## ❓ 20 Questions About Your Current Implementation

### Current APIs & Endpoints

**Q1:** Which API endpoints are you currently calling in the delivery man app?
   - [ ] `GET /api/v1/delivery-man/current-orders`
   - [ ] `GET /api/v1/delivery-man/latest-orders`
   - [ ] `PUT /api/v1/delivery-man/accept-order`
   - [ ] `PUT /api/v1/delivery-man/update-order-status`
   - [ ] `GET /api/v1/delivery-man/order`
   - [ ] Other (please list)

**Q2:** When you call `update-order-status` to pick up an order:
   - What fields do you currently send?
   - Do you always send `otp_store` field?
   - Is store OTP field always visible in your UI?

**Q3:** Do you currently check `module_id` in order responses?
   - [ ] Yes, we read `module_id` from API response
   - [ ] No, we don't check `module_id`
   - [ ] We check it sometimes but not everywhere

**Q4:** What headers do you send with API requests?
   - [ ] `Authorization: Bearer {token}`
   - [ ] `DeliverymanToken: {token}`
   - [ ] `moduleId: {id}` (in header)
   - [ ] Other headers?

---

### Current Store OTP Handling

**Q5:** Currently, when delivery man picks up an order:
   - Do you show a store OTP input field for ALL orders?
   - Or do you check module_id first?
   - What's your current UI flow for pickup?

**Q6:** When you call the pickup API, what happens if:
   - Store OTP is missing?
   - Store OTP is wrong?
   - Do you show error messages to the user?

**Q7:** For module 3 (HyperShella) orders currently:
   - How do delivery men get the store OTP?
   - Do they get it from the vendor app/employee?
   - Is it shown in the delivery man app?

---

### Current Order Status Handling

**Q8:** What order statuses does your app currently show in the order list?
   - [ ] `pending`
   - [ ] `confirmed`
   - [ ] `accepted`
   - [ ] `processing`
   - [ ] `picked_up`
   - [ ] `delivered`
   - [ ] All of the above

**Q9:** Currently, can delivery men see orders with status `pending`?
   - [ ] Yes, pending orders appear in the list
   - [ ] No, we only show `confirmed` orders
   - [ ] We filter by some other status
   
**Q9b:** When delivery man accepts an order, what status does it become?
   - [ ] `accepted`
   - [ ] `confirmed`
   - [ ] Other status?
   - [ ] We don't know/check

**Q10:** What statuses do you show as "available to accept"?
   - [ ] Only `confirmed`
   - [ ] Both `pending` and `confirmed`
   - [ ] Other statuses?

---

### Current UI/UX Implementation

**Q11:** In your order list screen, what information do you currently display?
   - Store name?
   - Store location?
   - Order amount?
   - Customer info?
   - Module type?
   - Other fields?

**Q12:** When showing order details, what do you currently display?
   - Store information (name, phone, address)?
   - Store location on map?
   - Order items?
   - Customer delivery address?
   - Store OTP field?
   - Customer OTP field?

**Q13:** Do you currently show any module-specific UI?
   - [ ] Yes, we show different UI for different modules
   - [ ] No, same UI for all orders
   - [ ] We show module type somewhere but don't change UI

**Q14:** In your pickup screen/flow, what do you currently show?
   - Store OTP input field?
   - Store information?
   - Navigation button?
   - Other elements?

**Q15:** In your delivery screen/flow, what do you currently show?
   - Customer OTP input field?
   - Customer address?
   - Navigation button?
   - Other elements?

**Q15b:** Do you currently allow uploading photos/images during order flow?
   - [ ] Yes, we can upload photos
   - [ ] No, we don't have photo upload functionality
   - [ ] We have it but only at delivery
   - [ ] Other (specify)

---

### Current Error Handling

**Q16:** How do you currently handle API errors?
   - Show error messages to user?
   - Retry failed requests?
   - Log errors?
   - Other error handling?

**Q17:** If an order fails to update status (e.g., wrong OTP), what happens?
   - Show error message?
   - Allow retry?
   - Cancel order?
   - Other behavior?

---

### Current Module Support

**Q18:** Currently, which modules does your app support?
   - [ ] Only module 3 (HyperShella)
   - [ ] Modules 3, 6, 7, 8
   - [ ] All modules
   - [ ] We don't know/care about modules

**Q19:** If you receive an order with `module_id: 6, 7, 8, or 9`:
   - Does your app handle it the same as module 3?
   - Or does it break/show errors?
   - Or does it work but might show wrong UI?

**Q20:** Do you currently have any module-specific code/logic in your app?
   - [ ] Yes, we check module_id in some places
   - [ ] No, we treat all orders the same
   - [ ] We have some module checks but not everywhere

**Q20b:** When delivery man accepts order, do you show different messages/statuses?
   - [ ] Same message for all orders
   - [ ] Different messages based on module
   - [ ] We show "Order Accepted" always

---

## 📱 What Changed in APIs

### API Endpoints - NO CHANGES ✅

All endpoints work exactly the same:
- ✅ Same URLs
- ✅ Same request format
- ✅ Same response format
- ✅ Same authentication

### API Responses - NEW DATA AVAILABLE

**Order Response Now Includes:**
```json
{
  "id": 12345,
  "module_id": 6,              // ✅ Available (was already there)
  "module_type": "food",       // ✅ Available (was already there)
  "order_status": "pending",   // ✅ Can be "pending" for modules 6/7/8/9
  "store": {
    "name": "Restaurant ABC",
    "phone": "+1234567890",
    "address": "...",
    "latitude": "...",
    "longitude": "..."
  }
}
```

---

### API Request Changes - ACCEPT ORDER BEHAVIOR

**Accept Order API - Changed for Modules 6/7/8/9:**

**Module 3 (HyperShella) - Existing Behavior:**
```json
PUT /api/v1/delivery-man/accept-order
{
  "order_id": 12345
}
```
- Order status: `pending` → `accepted`
- Vendor already confirmed the order
- Delivery man just accepts for delivery

**Modules 6, 7, 8, 9 - NEW Behavior:**
```json
PUT /api/v1/delivery-man/accept-order
{
  "order_id": 12345
}
```
- Order status: `pending` → `confirmed` (not `accepted`)
- Delivery man replaces vendor confirmation step
- Customer sees order confirmed immediately
- Sets `confirmed` timestamp

---

### API Request Changes - STORE OTP NOW OPTIONAL

**Pickup API - Module 3:**
```json
PUT /api/v1/delivery-man/update-order-status
{
  "status": "picked_up",
  "order_id": 12345,
  "otp_store": "1234"  // Required for module 3
}
```

**Pickup API - Modules 6, 7, 8, 9:**
```json
PUT /api/v1/delivery-man/update-order-status
{
  "status": "picked_up",
  "order_id": 12345
  // NO otp_store needed!
}
```

---

### API Request Changes - MENU/FACTURE PHOTO UPLOAD

**Upload Menu/Facture Photos (Modules 6/7/8/9 only):**
```json
PUT /api/v1/delivery-man/update-order-status
{
  "status": "confirmed",
  "order_id": 12345,
  "order_proof": [file1, file2, ...]  // Upload menu/facture photos before pickup
}
```
- Only works when order status is `confirmed`
- Only for modules 6, 7, 8, 9
- Delivery man pays at store, collects items, then uploads proof before pickup

---

## 🔍 What You Need to Check in Your Code

### 1. Accept Order - Status Changes

**Check:** What happens when delivery man accepts order?

**For Modules 6, 7, 8, 9:**
- When delivery man accepts → Order status becomes `confirmed` (not `accepted`)
- This replaces vendor confirmation step
- Customer sees "Order Confirmed" notification

**What You Need to Do:**
- After calling accept-order API, check the response status
- For modules 6/7/8/9, order status should be `confirmed`
- Show appropriate message to delivery man: "Order Confirmed" instead of "Order Accepted"

---

### 2. Store OTP Field Display

**Check:** Where do you show the store OTP input field?

**Current Behavior (probably):**
- Show store OTP field for all orders
- Require store OTP before pickup

**What You Need to Do:**
- Check `order.module_id` before showing store OTP field
- Only show/store OTP field for `module_id == 3`
- For modules 6, 7, 8, 9 - don't show/store OTP field

**Example Check:**
```dart
// Check if order needs store OTP
bool needsStoreOtp = order.moduleId == 3;

// Only show OTP field if needed
if (needsStoreOtp) {
  // Show store OTP field
} else {
  // Don't show store OTP field
}
```

---

### 2. Pickup API Call

**Check:** When calling pickup API, do you always send `otp_store`?

**Current Behavior (probably):**
- Always send `otp_store` field

**What You Need to Do:**
- Only send `otp_store` if `module_id == 3`
- Don't send `otp_store` for modules 6, 7, 8, 9

**Example:**
```dart
Map<String, dynamic> requestBody = {
  'status': 'picked_up',
  'order_id': orderId,
};

// Only add otp_store for module 3
if (order.moduleId == 3) {
  requestBody['otp_store'] = storeOtp;
}
```

---

### 3. Order Status Display

**Check:** Can delivery men see orders with status `pending`?

**Current Behavior:**
- Might only show `confirmed` orders
- Might filter out `pending` orders

**What Changed:**
- Orders from modules 6, 7, 8, 9 can be `pending` when delivery man sees them
- These pending orders should be shown and can be accepted

**What You Need to Do:**
- Make sure pending orders are shown in order list
- Allow accepting pending orders

---

### 4. Error Handling

**Check:** What happens if store OTP is missing or wrong?

**Current Behavior:**
- Probably shows error if store OTP missing/wrong

**What Changed:**
- For modules 6, 7, 8, 9 - no store OTP needed
- API will accept pickup without store OTP for these modules

**What You Need to Do:**
- Don't validate store OTP for modules 6, 7, 8, 9
- Only validate store OTP for module 3

---

## 🚨 Critical Things to Check

### 1. Store OTP Field ⚠️

**MUST CHECK:**
- Do you show store OTP field for all orders?
- If yes → You need to make it conditional (only for module 3)

**Impact:**
- If you show store OTP field for modules 6/7/8/9 → Confusion, errors
- If you require store OTP for modules 6/7/8/9 → Pickup will fail

---

### 2. Pickup API Call ⚠️

**MUST CHECK:**
- Do you always send `otp_store` when picking up?
- If yes → You need to make it conditional

**Impact:**
- If you send `otp_store` for modules 6/7/8/9 → API accepts it (optional), but unnecessary
- If you don't send it for module 3 → Pickup will fail (required)

---

### 5. Order Status Filtering ⚠️

**MUST CHECK:**
- Do you filter out `pending` orders?
- If yes → You might miss orders from modules 6/7/8/9

**Impact:**
- If you filter out pending → Orders from modules 6/7/8/9 won't appear
- These orders can be in pending status when delivery man sees them

---

## 📊 Module IDs Reference

### Module IDs:
- **Module 3:** HyperShella (Ecommerce) - Has vendor app, **needs store OTP**
- **Module 6:** Food - No vendor app, **no store OTP**
- **Module 7:** Grocery - No vendor app, **no store OTP**
- **Module 8:** Pharmacy - No vendor app, **no store OTP**
- **Module 9:** Drinks/Desserts - No vendor app, **no store OTP**

### Store OTP Rules:
- ✅ **Required:** Module 3 only
- ❌ **Not Required:** Modules 6, 7, 8, 9

### Customer OTP Rules:
- ✅ **Required:** All modules (for delivery)

---

## 🧪 Testing Checklist for You

### Test These Scenarios:

1. **Test Module 3 Order (Existing):**
   - [ ] Order appears in list
   - [ ] Store OTP field shows
   - [ ] Pickup requires store OTP
   - [ ] Pickup works with correct store OTP

2. **Test Module 6 Order (New):**
   - [ ] Order appears in list (can be `pending` status)
   - [ ] Store OTP field does NOT show
   - [ ] Pickup works without store OTP
   - [ ] Delivery requires customer OTP

3. **Test Module 7 Order (New):**
   - [ ] Same as module 6

4. **Test Module 8 Order (New):**
   - [ ] Same as module 6
   - [ ] Check if prescription indicator needed

5. **Test Module 9 Order (New):**
   - [ ] Same as module 6

---

## 🔗 API Response Examples

### Order from Module 3 (HyperShella):
```json
{
  "id": 12345,
  "module_id": 3,
  "module_type": "ecommerce",
  "order_status": "confirmed",
  "store": {
    "id": 1,
    "name": "هايبر شلة",
    "phone": "+1234567890"
  }
}
```
**Action:** Show store OTP field, require it for pickup

---

### Order from Module 6 (Food):
```json
{
  "id": 12346,
  "module_id": 6,
  "module_type": "food",
  "order_status": "pending",  // Can be pending!
  "store": {
    "id": 18,
    "name": "McDonald's KSA",
    "phone": "+1234567891"
  }
}
```
**Action:** Don't show store OTP field, pickup without OTP

---

### Order from Module 8 (Pharmacy):
```json
{
  "id": 12347,
  "module_id": 8,
  "module_type": "pharmacy",
  "order_status": "confirmed",
  "prescription_order": true,  // May have this field
  "store": {
    "id": 50,
    "name": "Al-Nahdi Pharmacy",
    "phone": "+1234567892"
  }
}
```
**Action:** Don't show store OTP field, pickup without OTP

---

## 💡 Backend Improvements Summary

### What We Changed:

1. ✅ **Delivery Man Replaces Vendor** - For modules 6/7/8/9, DM accepting = vendor confirming
2. ✅ **Accept = Confirm** - When DM accepts order, status becomes `confirmed` (not `accepted`)
3. ✅ **Store OTP Skipped** - Modules 6, 7, 8, 9 don't need store OTP
4. ✅ **Menu/Facture Photo Upload** - DM can upload order_proof before pickup (modules 6/7/8/9)
5. ✅ **Pending Orders Visible** - Delivery men see pending orders
6. ✅ **Module 9 Added** - Same as modules 6, 7, 8

### What We Didn't Change:

- ✅ All API endpoints work the same
- ✅ All API response formats the same
- ✅ Module 3 behavior unchanged
- ✅ Customer OTP still required

---

## 📝 What You Need to Do

### Step 1: Answer the 20 Questions

**Please tell us:**
1. What APIs you're currently using
2. How you currently handle store OTP
3. What your current UI looks like
4. What needs to change based on our updates

### Step 2: Check Your Code

**Must check:**
1. Where you show/store OTP field
2. Where you send/store OTP in API calls
3. How you filter order statuses
4. Any module-specific logic

### Step 3: Make Necessary Changes

**Based on your answers, we'll discuss:**
1. What needs to be updated in your code
2. How to handle store OTP conditionally
3. Any other adjustments needed

---

## 🚨 Important Notes

### Module ID Check is Critical:

**You MUST check `module_id` in your code to:**
- Show/hide store OTP field
- Send/don't send store OTP in API calls
- Handle orders correctly

**The API response already includes `module_id`** - you just need to use it!

---

### Order Status Can Be Pending:

**For modules 6, 7, 8, 9:**
- Orders can be `pending` when delivery man sees them
- These orders can be accepted immediately
- Don't filter out pending orders for these modules

---

### No Breaking Changes:

**All existing functionality works:**
- Module 3 orders work exactly the same
- All APIs work the same
- Only additions, no removals

---

## 📞 Next Steps

1. **Answer the 20 questions** - Tell us about your current implementation
2. **Review backend changes** - Understand what we changed
3. **Check your code** - Find where you need to make changes
4. **Discuss with backend team** - We'll help you implement changes
5. **Test together** - Make sure everything works

---

## 🔗 Related Documents

- `MODULES_6_7_8_API_ANALYSIS.md` - Full API analysis
- `MODULES_6_7_8_ORDER_FLOW.md` - Complete order flow documentation
- `FLUTTER_DELIVERY_MAN_APP_REQUIREMENTS.md` - Current API requirements

---

**Document Prepared By:** Backend Team  
**Date:** November 28, 2025  
**Status:** Ready for Flutter Team Review ✅

**Please answer all 20 questions and send back so we can discuss what needs to change!**

---

---

## 📋 Complete Order Flow for Modules 6, 7, 8, 9

### Step-by-Step Flow:

1. **Customer Creates Order**
   - Order status: `pending`
   - Customer sees: "Waiting for confirmation"
   - Delivery men receive notification

2. **Delivery Man Accepts Order**
   - API: `PUT /api/v1/delivery-man/accept-order`
   - Order status: `pending` → `confirmed`
   - Sets `confirmed` timestamp
   - Customer sees: "Order Confirmed" ✅

3. **Delivery Man Goes to Store**
   - Navigate to store location
   - Pay for order
   - Collect items

4. **Upload Menu/Facture Photos** (Optional but recommended)
   - API: `PUT /api/v1/delivery-man/update-order-status`
   - Status: `confirmed`
   - Upload: `order_proof` (photos of menu, facture, etc.)

5. **Pick Up Order**
   - API: `PUT /api/v1/delivery-man/update-order-status`
   - Status: `picked_up`
   - NO store OTP needed (only for module 3)

6. **Deliver Order**
   - API: `PUT /api/v1/delivery-man/update-order-status`
   - Status: `delivered`
   - Customer OTP required

---

**End of Document**
