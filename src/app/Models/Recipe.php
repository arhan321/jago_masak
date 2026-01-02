<?php

namespace App\Models;

use App\Models\Tag;
use App\Models\User;
use App\Models\Category;
use App\Models\Favorite;
use App\Models\RecipeStep;
use App\Models\RecipeIngredient;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Recipe extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id','category_id','title','description',
        'prep_time_minutes','cook_time_minutes','servings',
        'photo_path','is_published'
    ];

    protected $casts = [
        'is_published' => 'boolean',
        'prep_time_minutes' => 'integer',
        'cook_time_minutes' => 'integer',
        'servings' => 'integer',
    ];

    public function user()
    {
        return $this->hasMany(User::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function steps()
    {
        return $this->hasMany(RecipeStep::class)->orderBy('step_number');
    }

    public function ingredients()
    {
        return $this->hasMany(RecipeIngredient::class);
    }

    public function tags()
    {
        return $this->belongsToMany(Tag::class);
        // default pivot: recipe_tag (tag_id, recipe_id)
    }

    // public function favoritedBy()
    // {
    //     return $this->belongsToMany(User::class, 'favorites');
    // }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
    public function getPhotoUrlAttribute()
    {
        return $this->photo_path ? asset('storage/'.$this->photo_path) : null;
    }
}
