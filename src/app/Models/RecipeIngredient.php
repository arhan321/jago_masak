<?php

namespace App\Models;

use App\Models\Recipe;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class RecipeIngredient extends Model
{
    use HasFactory;

    protected $fillable = [
        'recipe_id',
        'name',
        'quantity',
        'unit',
    ];

    public function recipe()
    {
        return $this->belongsTo(Recipe::class);
    }
}
