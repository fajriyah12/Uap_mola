const { onSchedule } = require("firebase-functions/v2/scheduler");
const { getFirestore } = require("firebase-admin/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

const db = getFirestore();

// Jalankan setiap hari jam 01:00 pagi waktu Jakarta
exports.updateCompletedBookings = onSchedule({
  schedule: "0 1 * * *",
  timeZone: "Asia/Jakarta",
  region: "asia-southeast2", // Jakarta
}, async (event) => {
  try {
    const now = new Date();
    now.setHours(0, 0, 0, 0); // awal hari ini (00:00)

    console.log(`Mulai cek booking check-out ≤ ${now.toISOString()}`);

    const bookingsSnapshot = await db
      .collection("bookings") // ← PASTIKAN nama collection booking kamu "bookings"
      .where("bookingStatus", "==", "confirmed")
      .where("checkOutDate", "<=", admin.firestore.Timestamp.fromDate(now))
      .get();

    if (bookingsSnapshot.empty) {
      console.log("Tidak ada booking yang perlu di-update.");
      return null;
    }

    const batch = db.batch();
    let count = 0;

    bookingsSnapshot.forEach((doc) => {
      batch.update(doc.ref, { bookingStatus: "completed" });
      count++;
    });

    await batch.commit();

    console.log(`Sukses update ${count} booking jadi completed!`);
    return null;
  } catch (error) {
    console.error("Error:", error);
    return null;
  }
});