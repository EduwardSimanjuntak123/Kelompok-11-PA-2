const wd = require("wd");

// Membuat koneksi ke Appium server
const driver = wd.promiseRemote("http://localhost:4723"); // tanpa '/wd/hub'

// Konfigurasi pengujian dengan format capabilities W3C
const capabilities = {
  platformName: "Android",
  automationName: "Flutter",
  deviceName: "099344039M112293", // sesuaikan dengan nama device/emulator kamu
  appPackage: "com.example.flutter_rentalmotor", // sesuaikan dengan package aplikasi kamu
  appActivity: ".MainActivity", // sesuaikan dengan activity aplikasi kamu
  newCommandTimeout: 300,
};

const options = {
  capabilities: capabilities,
};

(async () => {
  try {
    // Menginisialisasi sesi pengujian
    await driver.init(options);
    console.log("Berhasil terkoneksi dengan aplikasi!");

    // Tambahkan langkah pengujian di sini
    await driver.quit(); // tutup sesi setelah pengujian selesai
  } catch (err) {
    console.error("Test gagal:", err);
  }
})();
