<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class CategoryController extends Controller
{
    // public
    // public function get()
    // {
    //     try {
    //         $category = Category::query()
    //             ->select(['id', 'name', 'created_at'])
    //             ->latest()
    //             ->get();

    //         return response()->json([
    //             'success' => true,
    //             'data' => $category,
    //         ], 200);

    //     } catch (\Throwable $e) {
    //         return response()->json([
    //             'success' => false,
    //             'message' => 'Terjadi kesalahan server',
    //             'error' => $e->getMessage(), // sementara untuk debug
    //         ], 500);
    //     }
    // }
    public function get()
    {
        $cats = \App\Models\Category::query()
            ->select('id', 'name')
            ->orderBy('name')
            ->get();
        return response()->json([
            'success' => true,
            'data' => $cats,
        ], 200);
    }

    // admin
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required','string','max:255','unique:categories,name'],
        ]);

        $category = Category::create($data);
        return response()->json($category, 201);
    }

    // admin
    public function update(Request $request, Category $category)
    {
        $data = $request->validate([
            'name' => ['required','string','max:255','unique:categories,name,' . $category->id],
        ]);

        $category->update($data);
        return response()->json($category);
    }

    // admin
    public function destroy(Category $category)
    {
        $category->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
