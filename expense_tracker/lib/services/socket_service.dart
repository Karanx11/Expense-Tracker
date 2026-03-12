import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io(
      "https://expense-backend-sz71.onrender.com/",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
  }

  void listenExpense(Function callback) {
    socket.on("expenseAdded", (data) {
      callback(data);
    });
  }
}
