<?php

use Illuminate\Http\Request;
use App\Http\Controllers\Api\ProcessoLicenciamentoController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Aqui é onde você pode registrar as rotas de API para sua aplicação.
| Estas rotas são carregadas pelo RouteServiceProvider e todas elas
| serão atribuídas ao grupo de middleware "api".
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

/**
 * Rota para fornecer os dados de processos de licenciamento para o frontend.
 */
Route::get('/processos', [ProcessoLicenciamentoController::class, 'index']);
