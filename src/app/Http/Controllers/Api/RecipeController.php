<?php

namespace App\Http\Controllers\Api;

use App\Models\Tag;
use App\Models\Recipe;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class RecipeController extends Controller
{
    // PUBLIC: list recipes published
    public function index(Request $request)
    {
        $q = Recipe::query()
            ->with(['category','tags'])
            ->where('is_published', true);

        if ($search = $request->query('search')) {
            $q->where('title', 'like', "%{$search}%");
        }
        if ($categoryId = $request->query('category_id')) {
            $q->where('category_id', $categoryId);
        }

        return $q->latest()->paginate(10);
    }

    // PUBLIC: show recipe (published), kalau belum published -> hanya owner/admin
    public function show(Request $request, Recipe $recipe)
    {
        $recipe->load(['user','category','tags','ingredients','steps']);

        if (!$recipe->is_published) {
            $user = $request->user(); // bisa null (public)
            $allowed = $user && ($user->id === $recipe->user_id || $user->isAdmin());
            abort_unless($allowed, 404); // disembunyikan dari publik
        }

        return $recipe;
    }

    // AUTH: my recipes
    public function myRecipes(Request $request)
    {
        return Recipe::with(['category','tags'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate(10);
    }

    // AUTH: create recipe
    public function store(Request $request)
    {
        $data = $this->validateRecipe($request, isUpdate: false);
        $data['user_id'] = $request->user()->id;

        return DB::transaction(function () use ($request, $data) {
            // upload photo (optional)
            if ($request->hasFile('photo')) {
                $data['photo_path'] = $request->file('photo')->store('recipes', 'public');
            }

            $recipe = Recipe::create($data);

            // ingredients & steps
            $recipe->ingredients()->createMany($data['ingredients'] ?? []);
            $recipe->steps()->createMany($data['steps'] ?? []);

            // tags
            $this->syncTags($recipe, $data['tags'] ?? []);

            return $recipe->load(['category','tags','ingredients','steps']);
        });
    }

    // AUTH: update recipe (owner/admin)
    public function update(Request $request, Recipe $recipe)
    {
        $this->authorizeOwnerOrAdmin($request, $recipe);

        $data = $this->validateRecipe($request, isUpdate: true);

        return DB::transaction(function () use ($request, $recipe, $data) {
            if ($request->hasFile('photo')) {
                $data['photo_path'] = $request->file('photo')->store('recipes', 'public');
            }

            $recipe->update($data);

            // replace ingredients & steps if present
            if ($request->has('ingredients')) {
                $recipe->ingredients()->delete();
                $recipe->ingredients()->createMany($data['ingredients'] ?? []);
            }

            if ($request->has('steps')) {
                $recipe->steps()->delete();
                $recipe->steps()->createMany($data['steps'] ?? []);
            }

            if ($request->has('tags')) {
                $this->syncTags($recipe, $data['tags'] ?? []);
            }

            return $recipe->load(['category','tags','ingredients','steps']);
        });
    }

    // AUTH: delete recipe (owner/admin)
    public function destroy(Request $request, Recipe $recipe)
    {
        $this->authorizeOwnerOrAdmin($request, $recipe);

        $recipe->delete();
        return response()->json(['message' => 'Deleted']);
    }

    // ADMIN: publish/unpublish
    public function publish(Request $request, Recipe $recipe)
    {
        $recipe->update(['is_published' => true]);
        return response()->json(['message' => 'Published']);
    }

    public function unpublish(Request $request, Recipe $recipe)
    {
        $recipe->update(['is_published' => false]);
        return response()->json(['message' => 'Unpublished']);
    }

    // -------------------------
    // Helpers
    // -------------------------
    private function authorizeOwnerOrAdmin(Request $request, Recipe $recipe): void
    {
        $user = $request->user();
        abort_unless($user->id === $recipe->user_id || $user->isAdmin(), 403);
    }

    private function validateRecipe(Request $request, bool $isUpdate): array
    {
        $sometimes = $isUpdate ? 'sometimes' : 'required';

        return $request->validate([
            'title' => [$sometimes,'string','max:255'],
            'description' => ['nullable','string'],
            'category_id' => ['nullable','exists:categories,id'],
            'prep_time_minutes' => ['nullable','integer','min:0'],
            'cook_time_minutes' => ['nullable','integer','min:0'],
            'servings' => ['nullable','integer','min:1'],
            'is_published' => ['sometimes','boolean'],

            // upload file via multipart/form-data
            'photo' => ['nullable','image','max:4096'],

            // tags: array of strings
            'tags' => ['sometimes','array'],
            'tags.*' => ['string','max:50'],

            // ingredients
            'ingredients' => ['sometimes','array'],
            'ingredients.*.name' => ['required_with:ingredients','string','max:255'],
            'ingredients.*.quantity' => ['nullable','string','max:50'],
            'ingredients.*.unit' => ['nullable','string','max:50'],

            // steps
            'steps' => ['sometimes','array'],
            'steps.*.step_number' => ['required_with:steps','integer','min:1'],
            'steps.*.instruction' => ['required_with:steps','string'],
        ]);
    }

    private function syncTags(Recipe $recipe, array $tags): void
    {
        $tagIds = collect($tags)
            ->map(fn ($t) => strtolower(trim($t)))
            ->filter()
            ->unique()
            ->map(fn ($name) => Tag::firstOrCreate(['name' => $name])->id)
            ->values()
            ->all();

        $recipe->tags()->sync($tagIds);
    }
}
