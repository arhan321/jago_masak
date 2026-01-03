<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class NotificationCotroller extends Controller
{
    // GET /api/notifications
    // Return JSON list saja (tanpa paginate)
    public function index(Request $request)
    {
        $data = Notification::query()
            ->orderByDesc('created_at')
            ->get();

        return response()->json($data, 200);
    }

    // GET /api/notifications/{notification}
    public function show(Notification $notification)
    {
        return response()->json($notification, 200);
    }

    // POST /api/notifications
    public function store(Request $request)
    {
        $payload = $request->validate([
            'judul' => ['nullable', 'string', 'max:255'],
            'deskripsi_notifikasi' => ['nullable', 'string'],
        ]);

        $notification = Notification::create($payload);

        return response()->json([
            'message' => 'Notifikasi berhasil dibuat.',
            'data' => $notification,
        ], 201);
    }

    // PUT/PATCH /api/notifications/{notification}
    public function update(Request $request, Notification $notification)
    {
        $payload = $request->validate([
            'judul' => ['nullable', 'string', 'max:255'],
            'deskripsi_notifikasi' => ['nullable', 'string'],
        ]);

        $notification->update($payload);

        return response()->json([
            'message' => 'Notifikasi berhasil diupdate.',
            'data' => $notification->fresh(),
        ], 200);
    }

    // DELETE /api/notifications/{notification}
    public function destroy(Notification $notification)
    {
        $notification->delete();

        return response()->json([
            'message' => 'Notifikasi berhasil dihapus.',
        ], 200);
    }
}
