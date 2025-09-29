# import random
# import time
# from google.cloud import firestore
# from datetime import datetime

# db = firestore.Client.from_service_account_json(
#     "stockapp-6c887-firebase-adminsdk-fbsvc-254e0329cb.json"
# )

# # Danh sách coin giả lập
# COINS = {
#     "btcusdt": 7416.44,
#     "ethusdt": 540.12,
#     "bnbusdt": 320.75,
#     "adausdt": 1.24,
#     "solusdt": 22.88
# }

# def generate_price_point(prev_price):
#     """
#     Tạo giá kế tiếp dựa trên giá trước đó, ±1% biến động.
#     """
#     delta_pct = random.uniform(-0.01, 0.01)  # ±1%
#     close_price = round(prev_price * (1 + delta_pct), 2)
    
#     # Giả lập open, high, low hợp lý
#     open_price = round(prev_price * (1 + random.uniform(-0.005, 0.005)), 2)
#     high_price = round(max(open_price, close_price) * (1 + random.uniform(0, 0.005)), 2)
#     low_price = round(min(open_price, close_price) * (1 - random.uniform(0, 0.005)), 2)
    
#     return {
#         "time": int(datetime.utcnow().timestamp()),
#         "open": open_price,
#         "close": close_price,
#         "high": high_price,
#         "low": low_price
#     }

# def init_coins():
#     """
#     Khởi tạo coins nếu chưa có dữ liệu.
#     """
#     for symbol, base_price in COINS.items():
#         doc_ref = db.collection("stocks").document(symbol)
#         if not doc_ref.get().exists:
#             price_point = generate_price_point(base_price)
#             doc_ref.set({
#                 "symbol": symbol,
#                 "name": symbol.upper(),
#                 "price": price_point["close"],
#                 "changePercent": 0.0,
#                 "volume": random.randint(1000, 5000),
#                 "updatedAt": firestore.SERVER_TIMESTAMP,
#                 "history": [price_point]
#             })
#     print("✅ Initialized coin data.")

# def update_prices():
#     """
#     Cập nhật giá liên tục theo từng coin.
#     """
#     while True:
#         for symbol in COINS.keys():
#             doc_ref = db.collection("stocks").document(symbol)
#             doc = doc_ref.get()
#             if doc.exists:
#                 data = doc.to_dict()
#                 old_price = data.get("price", COINS[symbol])
                
#                 # Tạo giá mới dựa trên giá cũ
#                 price_point = generate_price_point(old_price)
#                 change_percent = round(((price_point["close"] - old_price) / old_price) * 100, 2)
                
#                 # Cập nhật Firestore
#                 doc_ref.update({
#                     "price": price_point["close"],
#                     "changePercent": change_percent,
#                     "volume": random.randint(1000, 20000),
#                     "updatedAt": firestore.SERVER_TIMESTAMP,
#                     "history": firestore.ArrayUnion([price_point])
#                 })
                
#                 print(f"[{symbol}] {old_price} -> {price_point['close']} ({change_percent}%)")
#         time.sleep(1)  # update mỗi 3 giây

# if __name__ == "__main__":
#     init_coins()
#     update_prices()

import random
import time
from google.cloud import firestore
from datetime import datetime

db = firestore.Client.from_service_account_json(
    "stockapp-6c887-firebase-adminsdk-fbsvc-254e0329cb.json"
)

# Danh sách coin giả lập (giá khởi tạo + logo url)
COINS = {
    "btc": {
        "base": 7416.44,
        "logoUrl": "https://cryptologos.cc/logos/bitcoin-btc-logo.png"
    },
    "eth": {
        "base": 540.12,
        "logoUrl": "https://cryptologos.cc/logos/ethereum-eth-logo.png"
    },
    "xrp": {
        "base": 0.52,
        "logoUrl": "https://cryptologos.cc/logos/xrp-xrp-logo.png"
    },
    "bch": {
        "base": 210.55,
        "logoUrl": "https://cryptologos.cc/logos/bitcoin-cash-bch-logo.png"
    },
    "eos": {
        "base": 0.68,
        "logoUrl": "https://cryptologos.cc/logos/eos-eos-logo.png"
    },
    "ltc": {
        "base": 68.72,
        "logoUrl": "https://cryptologos.cc/logos/litecoin-ltc-logo.png"
    },
    "bnb": {
        "base": 320.75,
        "logoUrl": "https://cryptologos.cc/logos/bnb-bnb-logo.png"
    },
    "ada": {
        "base": 1.24,
        "logoUrl": "https://cryptologos.cc/logos/cardano-ada-logo.png"
    },
    "sol": {
        "base": 22.88,
        "logoUrl": "https://cryptologos.cc/logos/solana-sol-logo.png"
    },
}


def generate_price_point(prev_price):
    """
    Tạo giá kế tiếp dựa trên giá trước đó, ±1% biến động.
    """
    delta_pct = random.uniform(-0.01, 0.01)  # ±1%
    close_price = round(prev_price * (1 + delta_pct), 2)
    
    # Giả lập open, high, low hợp lý
    open_price = round(prev_price * (1 + random.uniform(-0.005, 0.005)), 2)
    high_price = round(max(open_price, close_price) * (1 + random.uniform(0, 0.005)), 2)
    low_price = round(min(open_price, close_price) * (1 - random.uniform(0, 0.005)), 2)
    
    return {
        "time": int(datetime.utcnow().timestamp()),
        "open": open_price,
        "close": close_price,
        "high": high_price,
        "low": low_price
    }

def init_coins():
    """
    Khởi tạo coins nếu chưa có dữ liệu.
    """
    for symbol, info in COINS.items():
        doc_ref = db.collection("stocks").document(symbol)
        if not doc_ref.get().exists:
            price_point = generate_price_point(info["base"])
            doc_ref.set({
                "symbol": symbol,
                "name": symbol.upper(),
                "logoUrl": info["logoUrl"],
                "price": price_point["close"],
                "changePercent": 0.0,
                "volume": random.randint(1000, 5000),
                "updatedAt": firestore.SERVER_TIMESTAMP,
                "history": [price_point]
            })
    print("✅ Initialized coin data.")

def update_prices():
    """
    Cập nhật giá liên tục theo từng coin.
    """
    while True:
        for symbol, info in COINS.items():
            doc_ref = db.collection("stocks").document(symbol)
            doc = doc_ref.get()
            if doc.exists:
                data = doc.to_dict()
                old_price = data.get("price", info["base"])
                
                # Tạo giá mới dựa trên giá cũ
                price_point = generate_price_point(old_price)
                change_percent = round(((price_point["close"] - old_price) / old_price) * 100, 2)
                
                # Cập nhật Firestore
                doc_ref.update({
                    "price": price_point["close"],
                    "changePercent": change_percent,
                    "volume": random.randint(1000, 20000),
                    "updatedAt": firestore.SERVER_TIMESTAMP,
                    "history": firestore.ArrayUnion([price_point])
                })
                
                print(f"[{symbol.upper()}] {old_price} -> {price_point['close']} ({change_percent}%)")
        time.sleep(1)  # update mỗi 1 giây

if __name__ == "__main__":
    init_coins()
    update_prices()
