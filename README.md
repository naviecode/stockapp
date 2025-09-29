# StockApp - Ứng dụng chứng khoán mô phỏng

StockApp là một ứng dụng di động được phát triển bằng **Flutter** kết hợp với **Firebase**, phục vụ cho việc quản lý danh mục đầu tư chứng khoán ảo. Ứng dụng cung cấp các chức năng quản lý tài khoản, giao dịch, danh mục đầu tư, theo dõi coin và nhận gợi ý từ AI.

---

## Tính năng chính

1. **Quản lý người dùng (Users)**
   - Đăng ký / Đăng nhập bằng Firebase Auth
   - Cập nhật thông tin cá nhân: tên, email, ảnh đại diện
   - Quản lý số dư ví ảo (balance)
   - Thời gian tạo và cập nhật tài khoản

2. **Danh sách coin (Stocks)**
   - Xem danh sách coin với giá hiện tại, biến động %, khối lượng
   - Lưu lịch sử giá trên biểu đồ
   - Dữ liệu coin có thể được sinh tự động bằng Python và cập nhật vào Firestore

3. **Giao dịch chứng khoán (Transactions)**
   - Mua / Bán coin
   - Lưu lịch sử giao dịch với thông tin: coin, số lượng, giá, tổng tiền
   - Giao dịch được liên kết với user và stock tương ứng

4. **Danh mục đầu tư (Portfolios)**
   - Theo dõi coin đang nắm giữ và số lượng
   - Giá trị trung bình mua của mỗi coin
   - Tổng giá trị danh mục và cập nhật theo thời gian thực

5. **Gợi ý AI (AI Recommendations)**
   - Phân tích xu hướng coin
   - Gợi ý: BUY | SELL | HOLD

6. **Thông báo (Notifications)**
   - Thông báo sự kiện liên quan đến coin
   - Đánh dấu đã đọc / chưa đọc
   - Lưu trữ lịch sử thông báo cho từng user

---