const PAYMENT_METHODS = [
  {
    id: "cod",
    name: "Cash on Delivery",
    description: "Pay with cash when your order arrives",
    requiresAction: false,
    fields: [],
  },
  {
    id: "wallet",
    name: "Wallet",
    description: "Pay instantly from wallet balance",
    requiresAction: true,
    fields: [
      { key: "walletPin", label: "Wallet PIN", type: "password", required: true },
    ],
  },
  {
    id: "bkash",
    name: "bKash",
    description: "Pay securely with bKash mobile account",
    requiresAction: true,
    fields: [
      { key: "phone", label: "bKash Number", type: "text", required: true },
      { key: "pin", label: "bKash PIN", type: "password", required: true },
    ],
  },
  {
    id: "card",
    name: "Bank Card",
    description: "Visa, Mastercard, Amex supported",
    requiresAction: true,
    fields: [
      { key: "cardNumber", label: "Card Number", type: "text", required: true },
      { key: "holderName", label: "Card Holder Name", type: "text", required: true },
      { key: "expiry", label: "Expiry (MM/YY)", type: "text", required: true },
      { key: "cvv", label: "CVV", type: "password", required: true },
    ],
  },
];

const getMethods = () => PAYMENT_METHODS;

const processPayment = ({ method, amount, payload = {} }) => {
  const selectedMethod = PAYMENT_METHODS.find((item) => item.id === method);
  if (!selectedMethod) {
    throw new Error("Invalid payment method");
  }

  for (const field of selectedMethod.fields) {
    if (field.required && !String(payload[field.key] ?? "").trim()) {
      throw new Error(`${field.label} is required`);
    }
  }

  return {
    status: "success",
    method: selectedMethod.id,
    methodName: selectedMethod.name,
    amount,
    transactionId: `TXN-${Date.now()}`,
  };
};

module.exports = {
  getMethods,
  processPayment,
};
