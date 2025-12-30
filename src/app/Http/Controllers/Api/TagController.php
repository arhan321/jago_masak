<?php

namespace App\Http\Controllers\Api;

use App\Models\Tag;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class TagController extends Controller
{
    // public
    public function index()
    {
        return Tag::orderBy('name')->get();
    }

    // admin
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required','string','max:255','unique:tags,name'],
        ]);

        $data['name'] = strtolower(trim($data['name']));
        $tag = Tag::create($data);

        return response()->json($tag, 201);
    }

    // admin
    public function update(Request $request, Tag $tag)
    {
        $data = $request->validate([
            'name' => ['required','string','max:255','unique:tags,name,' . $tag->id],
        ]);

        $tag->update(['name' => strtolower(trim($data['name']))]);
        return response()->json($tag);
    }

    // admin
    public function destroy(Tag $tag)
    {
        $tag->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
