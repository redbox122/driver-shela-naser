# 🚗 DELIVERY MAN APP - OTP VERIFICATION FIX GUIDE
**Team:** Delivery Man App (Flutter)  
**Priority:** CRITICAL  
**Estimated Time:** 45 minutes  
**Date:** October 29, 2025

---

## 🚨 THE PROBLEM

Your delivery man app is **MISSING CRITICAL OTP FIELDS** and **NOT SENDING OTP for pickup**. This breaks the entire pickup verification process!

---

## 🔑 UNDERSTANDING THE TWO OTPs - CRITICAL FOR DELIVERY MEN

### OTP 1: Store OTP (`otp_store`) - Example: 8560
- **Purpose:** Pickup verification at the restaurant
- **Who uses it:** VENDOR verifies YOU (DELIVERY MAN)
- **When:** At restaurant during pickup
- **What you do:** Show this OTP to the vendor, then enter it in your app

### OTP 2: Customer OTP (`otp`) - Example: 9563
- **Purpose:** Delivery verification at customer location
- **Who uses it:** CUSTOMER verifies YOU (DELIVERY MAN)
- **When:** At customer's address during delivery
- **What you do:** Ask customer for this OTP, then enter it in your app

---

## 🚗 How Delivery Man Uses Each OTP

### Phase 1: AT THE RESTAURANT - Store OTP (8560)

**Your Actions:**
1. You arrive at vendor's restaurant
2. You say: "I'm here to pick up Order #100203"
3. **Vendor asks you: "What's your pickup OTP?"**
4. **You check your app: "8560"**
5. **You tell vendor: "8560"**
6. Vendor verifies ✅ and hands over food
7. **You click "PICKED UP" in app**
8. **App asks for Store OTP**
9. **You enter: 8560**
10. Order status → picked_up ✅

**Purpose:** Proves YOU are the authorized delivery man (not someone stealing food)

### Phase 2: AT CUSTOMER'S HOME - Customer OTP (9563)

**Your Actions:**
1. You arrive at customer's address
2. You hand over the food
3. **You ask customer: "What's your delivery OTP?"**
4. **Customer checks their app: "9563"**
5. **Customer tells you: "9563"**
6. **You click "DELIVERED" in app**
7. **App asks for Customer OTP**
8. **You enter: 9563**
9. Order status → delivered ✅

**Purpose:** Proves you delivered to the CORRECT customer (not a random person)

---

## 📊 Complete Flow for Delivery Man:

```
ORDER CREATED
├── otp_store = 8560 (Store Pickup OTP - YOU SHOW THIS TO VENDOR)
└── otp = 9563 (Customer Delivery OTP - CUSTOMER SHOWS THIS TO YOU)

┌─────────────────────────────────────────────┐
│ YOUR APP DISPLAYS (after fix):               │
├─────────────────────────────────────────────┤
│ When order status = "handover":             │
│                                              │
│ 📦 Store Pickup OTP: 8560                   │
│    ↳ Show this to vendor at restaurant      │
└─────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────┐
│ PHASE 1: PICKUP (at Restaurant)             │
├─────────────────────────────────────────────┤
│ 1. You arrive at restaurant                 │
│ 2. Vendor asks: "What's your pickup OTP?"   │
│ 3. YOU show vendor: 8560 ✅                 │
│ 4. Vendor hands over food                   │
│ 5. You click "PICKED UP"                    │
│ 6. App prompts for Store OTP                │
│ 7. YOU enter: 8560                          │
│ 8. Backend verifies ✅                      │
│ 9. Status → picked_up                       │
└─────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────┐
│ YOUR APP DISPLAYS (after fix):               │
├─────────────────────────────────────────────┤
│ When order status = "picked_up":            │
│                                              │
│ 🚚 Customer Delivery OTP: 9563              │
│    ↳ Ask customer for this code             │
└─────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────┐
│ PHASE 2: DELIVERY (at Customer)             │
├─────────────────────────────────────────────┤
│ 1. You arrive at customer's home            │
│ 2. YOU ask customer: "What's your OTP?"     │
│ 3. Customer shows YOU: 9563 ✅              │
│ 4. You click "DELIVERED"                    │
│ 5. App prompts for Customer OTP             │
│ 6. YOU enter: 9563                          │
│ 7. Backend verifies ✅                      │
│ 8. Status → delivered                       │
└─────────────────────────────────────────────┘
```

### Summary Table for Delivery Man:

| OTP Type | At Which Location | Who Asks | Who Answers | What You Do |
|----------|------------------|----------|-------------|-------------|
| **Store OTP (8560)** | Restaurant | Vendor asks you | You answer | YOU show it to vendor, then enter it in app |
| **Customer OTP (9563)** | Customer's home | You ask customer | Customer answers | Customer shows it to YOU, then you enter it in app |

### 🔄 Remember:

**At Restaurant:** YOU are being verified (vendor checks if you're legit)
- Vendor asks you for Store OTP
- You show Store OTP from your app
- You enter Store OTP in your app to confirm pickup

**At Customer:** CUSTOMER is being verified (you check if it's the right customer)
- You ask customer for Customer OTP
- Customer shows Customer OTP from their app
- You enter Customer OTP in your app to confirm delivery

---

### What's Broken:

1. ❌ OrderModel missing `otp` and `otpStore` fields
2. ❌ Can't display OTPs to delivery man
3. ❌ Pickup action doesn't prompt for Store OTP
4. ❌ Sends `otp: null` instead of `otp_store: "8560"`
5. ❌ Pickup fails with validation error

### Current Flow (BROKEN):
```
DM arrives at restaurant
↓
DM clicks "PICKED UP" button
↓
❌ No OTP input dialog appears
↓
❌ App sends: { status: "picked_up", otp: null }
↓
❌ API REJECTS: "The store otp field is required"
↓
❌ DM stuck - can't mark order as picked up!
```

---

## ✅ THE FIX - COMPLETE STEP-BY-STEP GUIDE

### Fix #1: Add OTP Fields to OrderModel

**File:** `lib/features/order/domain/models/order_model.dart`

**Find your OrderModel class and add these fields:**

```dart
class OrderModel {
  final int? id;
  final double? orderAmount;
  final String? orderStatus;
  final String? paymentStatus;
  final String? paymentMethod;
  
  // ... existing fields ...
  
  // ✅ ADD THESE TWO FIELDS:
  final String? otp;         // Customer OTP (for delivery verification)
  final String? otpStore;    // Store OTP (for pickup verification)
  
  OrderModel({
    this.id,
    this.orderAmount,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMethod,
    
    // ✅ ADD TO CONSTRUCTOR:
    this.otp,
    this.otpStore,
    
    // ... other fields ...
  });
  
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      orderAmount: (json['order_amount'] as num?)?.toDouble(),
      orderStatus: json['order_status'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      
      // ✅ ADD THESE TWO LINES:
      otp: json['otp'],
      otpStore: json['otp_store'],  // Note: API sends as 'otp_store', not 'otpStore'
      
      // ... other fields ...
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_amount': orderAmount,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      
      // ✅ ADD THESE:
      'otp': otp,
      'otp_store': otpStore,
      
      // ... other fields ...
    };
  }
}
```

---

### Fix #2: Display OTPs on Order Details Screen

**File:** `lib/features/order/screens/order_details_screen.dart`

**Add OTP display widget that shows different OTPs based on order status:**

```dart
Widget _buildOtpSection(OrderModel order) {
  // Only show OTPs for relevant order statuses
  if (!['handover', 'picked_up', 'delivered'].contains(order.orderStatus)) {
    return SizedBox.shrink();
  }
  
  return Container(
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (order.orderStatus == 'handover') ...[
          // Show Store OTP when ready for pickup
          _buildOtpCard(
            icon: Icons.store,
            label: 'Store Pickup Code',
            otp: order.otpStore ?? 'N/A',
            description: 'Ask the vendor for this code to collect the order',
            color: Colors.blue,
          ),
        ],
        if (order.orderStatus == 'picked_up') ...[
          // Show Customer OTP when out for delivery
          _buildOtpCard(
            icon: Icons.person,
            label: 'Customer Delivery Code',
            otp: order.otp ?? 'N/A',
            description: 'Ask the customer for this code when you arrive',
            color: Colors.green,
          ),
        ],
      ],
    ),
  );
}

Widget _buildOtpCard({
  required IconData icon,
  required String label,
  required String otp,
  required String description,
  required Color color,
}) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                otp,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

**Then add this to your order details screen layout:**

```dart
// In your order details screen build method:
Column(
  children: [
    // ... other order info widgets ...
    
    _buildOtpSection(order), // ← ADD THIS LINE
    
    // ... rest of the layout ...
  ],
)
```

---

### Fix #3: Add Store OTP Input Dialog for Pickup

**File:** `lib/features/order/screens/order_details_screen.dart`

**When delivery man clicks "PICKED UP" button, show OTP input dialog:**

```dart
Future<void> _handlePickupOrder() async {
  // Show dialog to input store OTP
  String? storeOtp = await _showStoreOtpDialog();
  
  if (storeOtp == null || storeOtp.isEmpty) {
    // User cancelled
    return;
  }
  
  // Call API with store OTP
  await _updateOrderStatus('picked_up', storeOtp: storeOtp);
}

Future<String?> _showStoreOtpDialog() async {
  String? storeOtp;
  
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.store, color: Colors.blue),
            SizedBox(width: 8),
            Text('Enter Store Pickup Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ask the vendor for the pickup code to verify this order.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                hintText: '____',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                storeOtp = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Verify'),
          ),
        ],
      );
    },
  );
  
  return storeOtp;
}
```

---

### Fix #4: Update API Call to Send Store OTP

**File:** `lib/features/order/controllers/order_controller.dart`

**Find your `updateOrderStatus` method and modify it:**

```dart
// BEFORE (BROKEN):
Future<void> updateOrderStatus({
  required String orderId,
  required String status,
}) async {
  final body = {
    'token': authToken,
    'order_id': orderId,
    'status': status,
  };
  
  if (status == 'delivered') {
    body['otp'] = customerOtp; // ✅ OK - for delivery
  } else if (status == 'picked_up') {
    body['otp'] = null; // ❌ WRONG! Should be otp_store
  }
  
  // Make API call...
}

// AFTER (FIXED):
Future<void> updateOrderStatus({
  required String orderId,
  required String status,
  String? storeOtp,  // ✅ NEW PARAMETER
  String? customerOtp, // ✅ Already have this
}) async {
  final body = {
    'token': authToken,
    'order_id': orderId,
    'status': status,
  };
  
  // ✅ For delivery: send customer OTP
  if (status == 'delivered' && customerOtp != null) {
    body['otp'] = customerOtp;
  }
  
  // ✅ For pickup: send store OTP
  if (status == 'picked_up' && storeOtp != null) {
    body['otp_store'] = storeOtp;  // ✅ FIXED: Use otp_store field name
  }
  
  // Make API call...
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/delivery-man/update-order-status'),
    body: body,
    headers: {'DeliverymanToken': authToken},
  );
  
  if (response.statusCode == 200) {
    // Success
  } else {
    // Handle error
  }
}
```

---

### Fix #5: Add Customer OTP Dialog for Delivery

**If you don't already have this, add it:**

```dart
Future<void> _handleDeliverOrder() async {
  // Show dialog to input customer OTP
  String? customerOtp = await _showCustomerOtpDialog();
  
  if (customerOtp == null || customerOtp.isEmpty) {
    return;
  }
  
  // Call API with customer OTP
  await _updateOrderStatus('delivered', customerOtp: customerOtp);
}

Future<String?> _showCustomerOtpDialog() async {
  String? customerOtp;
  
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.green),
            SizedBox(width: 8),
            Text('Enter Customer Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ask the customer for their delivery verification code.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                hintText: '____',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                customerOtp = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Verify & Deliver'),
          ),
        ],
      );
    },
  );
  
  return customerOtp;
}
```

---

## 🧪 TESTING CHECKLIST

After implementing all fixes:

### Test Pickup Flow:
```
□ 1. Login as delivery man
□ 2. Accept an order
□ 3. Navigate to order in "handover" status
□ 4. CHECK: Can you see Store OTP displayed? YES/NO
□ 5. Click "PICKED UP" button
□ 6. CHECK: Does OTP input dialog appear? YES/NO
□ 7. Enter correct Store OTP (ask vendor or check API response)
□ 8. Click "Verify"
□ 9. CHECK: Does order status change to "picked_up"? YES/NO
□ 10. If NO: What error message do you see? ___________
```

### Test Delivery Flow:
```
□ 11. Order is now "picked_up"
□ 12. CHECK: Can you see Customer OTP displayed? YES/NO
□ 13. Click "DELIVERED" button
□ 14. CHECK: Does OTP input dialog appear? YES/NO
□ 15. Enter correct Customer OTP
□ 16. Click "Verify & Deliver"
□ 17. CHECK: Does order status change to "delivered"? YES/NO
□ 18. CHECK: Does payment process successfully? YES/NO
```

---

## 🚨 ERROR TROUBLESHOOTING

### Error: "The store otp field is required"
**Cause:** Not sending `otp_store` parameter  
**Fix:** Add `body['otp_store'] = storeOtp;` in your API call

### Error: "Otp Not matched"
**Cause:** Wrong OTP value entered  
**Fix:** Verify you're using the correct OTP from API response

### Error: "otp_store field not found"
**Cause:** Field name mismatch  
**Fix:** Use exactly `'otp_store'` (with underscore, lowercase)

### Order OTP shows "null"
**Cause:** OrderModel not parsing field  
**Fix:** Add `otpStore: json['otp_store']` in `fromJson`

---

## 📸 EXAMPLE UI FLOW

### Screen 1: Order Ready for Pickup
```
┌─────────────────────────────────────┐
│  ORDER #100203                      │
│  Status: Ready for Pickup          │
├─────────────────────────────────────┤
│  📦 Store Pickup Code              │
│  🏪                    8560        │
│  Ask the vendor for this code to   │
│  collect the order                 │
├─────────────────────────────────────┤
│  [PICKED UP]                       │
└─────────────────────────────────────┘
```

### Screen 2: Pickup OTP Dialog
```
┌─────────────────────────────────────┐
│  🏪 Enter Store Pickup Code        │
├─────────────────────────────────────┤
│  Ask the vendor for the pickup     │
│  code to verify this order.        │
│                                     │
│  [ 8 5 6 0 ]                       │
│                                     │
│  [Cancel]  [Verify]                │
└─────────────────────────────────────┘
```

### Screen 3: Out for Delivery
```
┌─────────────────────────────────────┐
│  ORDER #100203                      │
│  Status: Out for Delivery          │
├─────────────────────────────────────┤
│  🚚 Customer Delivery Code         │
│  👤                    9563        │
│  Ask the customer for this code    │
│  when you arrive                   │
├─────────────────────────────────────┤
│  [DELIVERED]                       │
└─────────────────────────────────────┘
```

---

## ✅ EXPECTED RESULT

After all fixes:
- ✅ Delivery man can see Store OTP before pickup
- ✅ Delivery man enters Store OTP when collecting order
- ✅ Pickup succeeds with correct verification
- ✅ Delivery man can see Customer OTP during delivery
- ✅ Delivery man enters Customer OTP at customer location
- ✅ Delivery succeeds with correct verification
- ✅ Complete end-to-end flow works perfectly

---

## 📞 IF YOU NEED HELP

1. **Check API Response:** Call `/api/v1/delivery-man/order-details?order_id=XXXX` and verify both OTPs are present
2. **Debug Logs:** Add `print('Store OTP: ${order.otpStore}, Customer OTP: ${order.otp}');`
3. **Contact Backend:** Verify field names are correct (`otp_store` not `store_otp`)

---

**Questions? Contact:** Backend Team  
**Priority:** CRITICAL - This blocks all order deliveries  
**Deadline:** ASAP - Customers are waiting

