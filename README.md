# StockApp - Ứng dụng chứng khoán mô phỏng

StockApp là một ứng dụng di động được phát triển bằng **Flutter** kết hợp với **Firebase**, phục vụ cho việc quản lý danh mục đầu tư chứng khoán ảo. Ứng dụng cung cấp các chức năng quản lý tài khoản, giao dịch, danh mục đầu tư, theo dõi cổ phiếu và nhận gợi ý từ AI.

---

## Tính năng chính

1. **Quản lý người dùng (Users)**
   - Đăng ký / Đăng nhập bằng Firebase Auth
   - Cập nhật thông tin cá nhân: tên, email, ảnh đại diện
   - Quản lý số dư ví ảo (balance)
   - Thời gian tạo và cập nhật tài khoản

2. **Danh sách cổ phiếu (Stocks)**
   - Xem danh sách cổ phiếu với giá hiện tại, biến động %, khối lượng
   - Lưu lịch sử giá trên biểu đồ
   - Dữ liệu cổ phiếu có thể được sinh tự động bằng Python và cập nhật vào Firestore

3. **Giao dịch chứng khoán (Transactions)**
   - Mua / Bán cổ phiếu
   - Lưu lịch sử giao dịch với thông tin: cổ phiếu, số lượng, giá, tổng tiền
   - Giao dịch được liên kết với user và stock tương ứng

4. **Danh mục đầu tư (Portfolios)**
   - Theo dõi cổ phiếu đang nắm giữ và số lượng
   - Giá trị trung bình mua của mỗi cổ phiếu
   - Tổng giá trị danh mục và cập nhật theo thời gian thực

5. **Gợi ý AI (AI Recommendations)**
   - Phân tích xu hướng cổ phiếu
   - Gợi ý: BUY | SELL | HOLD

6. **Thông báo (Notifications)**
   - Thông báo sự kiện liên quan đến cổ phiếu
   - Đánh dấu đã đọc / chưa đọc
   - Lưu trữ lịch sử thông báo cho từng user

---

## Cấu trúc Firestore

