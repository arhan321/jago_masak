<?php

namespace App\Http\Controllers\Api;

use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class CategoryController extends Controller
{
    // public
    public function index()
    {
        $category = DB::connection('mysql')->table('categories')->get();
        return response()->json($category, 200);
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
