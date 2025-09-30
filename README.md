<h1> App Đặt Món Ăn cho Mobile (Food Order Mobile App) </h1>

<h2> Backend: Firebase <br />
<br />
Frontend: Flutter </h2>


<h3> Trang đăng ký </h3>

<img width="276" height="633" alt="image" src="https://github.com/user-attachments/assets/ee8fd2a0-fd97-4992-9e5f-26f3361499b9" />


Trang được sử dụng làm giao diện để người dùng đăng ký. Nó bao gồm các Field để người dùng nhập tên, email, mật khẩu và số điện thoại. 
Khi nhấn nút "Đăng ký", nó gọi hàm dangKyTaiKhoan từ dangky.dart để đăng ký người dùng sử dụng Firebase Authentication và lưu thông tin của họ vào Firestore. Nếu đăng ký thành công, người dùng sẽ được chuyển hướng đến màn hình đăng nhập.
dangky.dart gồm các logic để đăng ký người dùng. Sử dụng Firebase Authentication để tạo một tài khoản người dùng. Sau khi người dùng đăng ký thành công, thông tin của người dùng (tên, email, số điện thoại và vai trò) được lưu vào cơ sở dữ liệu Firestore trong collection nguoi_dung. Vai trò mặc định được đặt là nguoi_dung (người dùng thông thường). Nếu đăng ký thành công, một thông báo thành công sẽ được hiển thị nếu không, lỗi sẽ được bắt và hiển thị.

 
<h3> Trang đăng nhập </h3>

<img width="278" height="635" alt="image" src="https://github.com/user-attachments/assets/ad9b6ccd-b213-4c3f-8126-21a2cc1c7aa8" />


dangnhap.dart xử lý chức năng đăng nhập của người dùng. Sử dụng Firebase Authentication để xác thực người dùng. Sau khi đăng nhập thành công, vai trò của người dùng từ collection người dùng (nguoi_dung) trong Firestore được lấy để so sánh. Nếu là admin sẽ chuyển đến trang quản lý admin, nếu là người dùng sẽ chuyển đến trang chủ. Nếu đăng nhập thất bại, thông báo lỗi sẽ hiển thị dưới dạng SnackBar.
Trang đăng nhập hiển thị giao diện  đăng nhập. Bao gồm các trường nhập liệu (Field) cho email và mật khẩu. Khi nhấn nút "Đăng nhập", nó gọi hàm _dangNhap trong dangnhap.dart để xác thực người dùng thông qua Firebase Authentication và lấy vai trò từ Firestore. Dựa trên vai trò, người dùng sẽ được chuyển hướng đến trang phù hợp (trang chủ hoặc trang admin).
Nếu người dùng không có tài khoản, bấm vào Đăng ký ngay để chuyển trang đăng ký.
 
<h3> Trang chủ </h3>

<img width="298" height="682" alt="image" src="https://github.com/user-attachments/assets/7193417d-635c-493d-952b-67ab025afa21" />


Màn hình chính dành cho người dùng khi đăng nhập. Hiển thị danh sách các món ăn được lấy từ collection món ăn (mon_an) trong Firestore. Người dùng có thể tìm kiếm món ăn, thêm chúng vào giỏ hàng và điều hướng đến các phần khác như đơn hàng và hồ sơ. Chức năng giỏ hàng tương tác với collection carts trong Firestore để thêm hoặc cập nhật các món ăn.
 
<h3> Chức năng tìm kiếm </h3> 

<img width="307" height="702" alt="image" src="https://github.com/user-attachments/assets/735bc270-40a0-4d36-aa2a-a89f096952cd" />


Chức năng tìm kiếm món ăn cho phép người dùng tìm kiếm và hiển thị danh sách các món ăn từ cơ sở dữ liệu Firestore (collection mon_an) theo thời gian thực. Người dùng nhập từ khóa vào thanh tìm kiếm, hệ thống sẽ đẩy từ khóa này vào một Stream để lọc danh sách món ăn phù hợp. Nếu không có từ khóa, toàn bộ danh sách món ăn sẽ được hiển thị. Ngược lại, khi nhập từ khóa, hệ thống chỉ hiển thị các món ăn có tên chứa từ khóa đó (không phân biệt chữ hoa, chữ thường). Danh sách món ăn được hiển thị dưới dạng danh sách cuộn, mỗi món bao gồm tên, mô tả, hình ảnh và nút thêm vào giỏ hàng. Nếu không có món ăn nào phù hợp với từ khóa, hệ thống sẽ hiển thị thông báo "Không tìm thấy món ăn phù hợp". Chức năng này đảm bảo tính tiện lợi và tốc độ, giúp người dùng dễ dàng tìm kiếm món ăn mong muốn.

 
<h3> Xem chi tiết món ăn và nhận xét </h3>

<img width="290" height="663" alt="image" src="https://github.com/user-attachments/assets/fa567dfa-fe07-491b-aee3-6f5ec1279635" />

Chức năng này cho phép người dùng xem chi tiết thông tin của một món ăn và gửi nhận xét về món ăn đó. Giao diện chi tiết món ăn hiển thị các thông tin bao gồm tên, mô tả, hình ảnh, và giá món ăn. Người dùng có thể nhấn nút "Thêm vào giỏ hàng" để thêm món ăn vào collection carts trong Firestore với thông tin như tên, giá, hình ảnh, và số lượng (mặc định là 1). Nếu món ăn đã tồn tại trong giỏ hàng, số lượng sẽ được tăng thêm. Khi thêm thành công, một thông báo xác nhận sẽ hiển thị.
Ngoài ra, giao diện còn hỗ trợ hiển thị danh sách các nhận xét về món ăn từ collection nhan_xet trong Firestore. Các nhận xét được sắp xếp theo thứ tự mới nhất và bao gồm thông tin về người dùng, nội dung nhận xét, và thời gian gửi nhận xét. Nếu chưa có nhận xét nào, hệ thống sẽ hiển thị thông báo "Chưa có nhận xét nào."
Người dùng có thể gửi nhận xét mới thông qua một ô nhập liệu phía dưới giao diện. Sau khi nhập nội dung nhận xét và nhấn nút gửi, nhận xét sẽ được lưu vào collection nhan_xet với các thông tin như ID món ăn, ID người dùng, nội dung nhận xét, và thời gian gửi. Nếu gửi nhận xét thành công, thông báo xác nhận sẽ được hiển thị, ngược lại, nếu gặp lỗi, hệ thống sẽ báo lỗi để người dùng biết. Chức năng này giúp người dùng dễ dàng quản lý giỏ hàng, chia sẻ ý kiến cá nhân, và tăng tính tương tác trên ứng dụng.


<h3> Giỏ hàng </h3> 

<img width="254" height="581" alt="image" src="https://github.com/user-attachments/assets/51b1df1b-c518-4e38-82ef-391312de50be" />

Khi người dùng thêm món ăn vào giỏ hàng,  dữ liệu sẽ lưu vào collection giỏ hàng (carts) trong Firestore dưới ID của người dùng, nếu người dùng chuyển qua trang giỏ hàng, dữ liệu trong collection giỏ hàng sẽ hiện ra gồm giá, hình ảnh, số lượng, tên món.
Người dùng có thể điều chỉnh số lượng món ăn hoặc xóa khỏi giỏ hàng, dữ liệu giỏ hàng trong Firestore sẽ được cập nhật khi thêm số lượng hoặc xóa khỏi giỏ hàng. 
Trang giỏ hàng còn có nút để chuyển đến màn hình thanh toán để hoàn tất đơn hàng.
 
<h3> Thanh toán hóa đơn COD và VNPay </h3>

<img width="279" height="637" alt="image" src="https://github.com/user-attachments/assets/aaba6c8e-7b63-487d-be44-a9eb9a3424a6" />


Màn hình sử dụng để xử lý quy trình thanh toán cho các đơn hàng. Nó tính toán tổng chi phí của các món ăn trong giỏ hàng và cho phép người dùng chọn giữa thanh toán COD (tiền mặt khi nhận hàng) và VNPay. Nếu người dùng chọn VNPay, file này tích hợp với API VNPay để xử lý thanh toán. 
Khi thanh toán thành công, chi tiết đơn hàng được lưu vào collection đơn hàng (don_hang) trong Firestore, và giỏ hàng của người dùng sẽ được xóa.
 
<h3> Giao diện đơn hàng thanh toán qua VNPay </h3>

<img width="304" height="694" alt="image" src="https://github.com/user-attachments/assets/f607a9c4-7e0e-48e3-9b2a-4b6a9e1060ed" />


Chức năng này cho phép người dùng thực hiện thanh toán đơn hàng qua cổng thanh toán VNPay. Người dùng nhập thông tin bao gồm tên người nhận và địa chỉ giao hàng để hoàn tất đơn hàng.
Tổng tiền của giỏ hàng được tính toán dựa trên giá và số lượng của từng món ăn trong giỏ. Khi chọn thanh toán VNPay, hệ thống sẽ tạo liên kết thanh toán thông qua API của VNPay với các thông tin như mã đơn hàng, tổng tiền, và thời gian hết hạn. Khi thanh toán thành công, VNPay trả về mã phản hồi, đồng thời đơn hàng được ghi vào collection don_hang trên Firestore với trạng thái "Đã thanh toán qua VNPay". Sau khi đặt hàng, hệ thống xóa các mục trong giỏ hàng để đảm bảo dữ liệu luôn được cập nhật.
Chức năng này đảm bảo quá trình thanh toán an toàn, nhanh chóng và cung cấp tùy chọn thanh toán linh hoạt cho người dùng. Sau khi thanh toán thành công, hệ thống tự động điều hướng người dùng về trang chủ để tiếp tục trải nghiệm ứng dụng.


 
<h3>Đơn hàng của user </h3> 

<img width="293" height="670" alt="image" src="https://github.com/user-attachments/assets/049f4886-1312-4c67-9122-ba9762eb24ac" />


Hiển thị danh sách các đơn hàng mà người dùng đã đặt. Các đơn hàng được lấy từ collection đơn hàng (don_hang) trong Firestore, các đơn hàng hiển thị được lọc theo ID của người dùng. Mỗi đơn hàng được hiển thị với ID, tổng chi phí, trạng thái và ngày đặt. Người dùng có thể nhấn vào để chuyển đến trang chi tiết đơn hàng để xem chi tiết hàng đã đặt

  
<h3> Xem chi tiết đơn hàng và xác nhận đã nhận hàng </h3>

<img width="256" height="585" alt="image" src="https://github.com/user-attachments/assets/f049d5aa-3af1-4874-b8f9-4d7a09e71a8f" />


Chi tiết đơn hàng hiển thị thông tin chi tiết về một đơn hàng cụ thể từ collection đơn hàng (don_hang) và từ collection con chi tiết đơn hàng (chi_tiet_don_hang) gồm có giá, hình ảnh, số lượng, tên món trong Firestore. 
Màn hình hiển thị danh sách các món ăn trong đơn hàng, cùng với số lượng và giá của chúng. Nếu trạng thái đơn hàng là "Đã giao hàng", người dùng có thể xác nhận đã nhận hàng, trạng thái sẽ được cập nhật thành "Hoàn thành" trong Firestore.
 
<h3> Xem thông tin và thêm, xóa, sửa người dùng của Admin </h3>

<img width="290" height="664" alt="image" src="https://github.com/user-attachments/assets/b2777bc6-d52c-4ef2-9bac-f306bb6ddc74" />

Trang cho phép admin quản lý người dùng. Nó lấy dữ liệu người dùng từ collection người dùng (nguoi_dung) trong Firestore và hiển thị dưới dạng danh sách. 
Admin có thể thêm người dùng mới, sửa thông tin người dùng hiện có hoặc xóa người dùng. Trang cho phép admin gán vai trò (ví dụ: "nguoi_dung" hoặc "admin") cho người dùng, được lưu trong Firestore.
 
<h3> Xem thông tin và thêm, xóa, sửa món ăn của Admin </h3> 

<img width="257" height="588" alt="image" src="https://github.com/user-attachments/assets/f5c28e65-f833-43e8-9d32-ec12190b8f16" />

Quản lý món ăn cho phép admin quản lý các món ăn. Được dùng để hiển thị món ăn, thêm, sửa và xóa các món ăn trong collection món ăn (mon_an) trong Firebase. 
Admin có thể liên kết món ăn với các nhà hàng bằng cách chọn nhà hàng từ menu thả xuống. 
Trang còn hỗ trợ tải lên hình ảnh sử dụng packages image_picker cho các món ăn, được lưu dưới dạng đường dẫn file trong Firestore.

 
<h3>Xem thông tin và thêm, xóa, sửa nhà hàng của Admin </h3>

<img width="260" height="595" alt="image" src="https://github.com/user-attachments/assets/8b38fdee-aa69-46d2-9e13-f31b17682447" />

Quản lý nhà hàng cho phép admin quản lý nhà hàng. Được dùng để thêm, sửa và xóa các nhà hàng trong collection nhà hàng (nha_hang) trong Firestore. 
Admin có thể nhập các chi tiết như tên nhà hàng, địa chỉ và số điện thoại. 

 
<h3> Xem thông tin và sửa hóa đơn của Admin </h3>

<img width="293" height="669" alt="image" src="https://github.com/user-attachments/assets/4844f46e-05d9-43cc-9005-62fe64d5438b" />

Trang cho phép admin quản lý các đơn hàng. Các đơn hàng được láy từ  collection đơn hàng (don_hang) trong Firestore và hiển thị dưới dạng danh sách. 
Admin có thể xem chi tiết đơn hàng hoặc thay đổi trạng thái đơn hàng.

 
<h3> Chỉnh sửa trạng thái đơn hàng </h3>

<img width="324" height="740" alt="image" src="https://github.com/user-attachments/assets/17b24dd7-3744-45e1-92fc-400616d3b97e" />

Admin có thể cập nhật trạng thái của đơn hàng (ví dụ: "Đang xử lý", "Đã giao hàng") bằng cách chọn trạng thái mới từ menu. Trạng thái mới sau đó được lưu lại vào Firestore.
