<?php

namespace App\Http\Controllers;

use App\Models\saran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class saranController extends Controller
{
  // GET /api/sarans
    public function index()
    {
        $sarans = saran::query()
            ->select('id', 'name', 'pesan', 'created_at')
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'List saran berhasil diambil',
            'data' => $sarans,
        ], 200);
    }

    public function total()
    {
        $total = saran::count();

        return response()->json([
            'total_saran' => $total,
        ], 200);
    }


    // POST /api/sarans
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['nullable', 'string', 'max:100'],
            'pesan' => ['required', 'string', 'max:1000'],
        ]);

        $saran = saran::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Saran berhasil dikirim',
            'data' => $saran,
        ], 201);
    }

    
}
