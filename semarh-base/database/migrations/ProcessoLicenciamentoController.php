<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProcessoLicenciamento;
use Illuminate\Http\Request;

class ProcessoLicenciamentoController extends Controller
{
    /**
     * Exibe uma lista dos recursos.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        // --- USO COM DADOS REAIS (após popular o banco) ---
        // Descomente a linha abaixo para usar dados do banco de dados.
        // return response()->json(ProcessoLicenciamento::latest()->get());

        // --- USO COM DADOS DE EXEMPLO (mock) ---
        // Mantendo os dados de exemplo para que o frontend continue funcionando.
        $processos = [
            ['id' => 1, 'numero_pa' => '2026/0189-LIC', 'requerente' => 'Empresa Exemplo LTDA', 'tipo_licenca' => 'Licença de Operação (LO)', 'status' => 'DEFERIDO'],
            ['id' => 2, 'numero_pa' => '2026/0190-LIC', 'requerente' => 'Construtora Viver Bem', 'tipo_licenca' => 'Licença de Instalação (LI)', 'status' => 'EM ANÁLISE'],
            ['id' => 3, 'numero_pa' => '2026/0191-AUT', 'requerente' => 'João da Silva', 'tipo_licenca' => 'Autorização de Supressão', 'status' => 'PENDENTE'],
            ['id' => 4, 'numero_pa' => '2026/0192-LIC', 'requerente' => 'Indústria Metalúrgica S.A.', 'tipo_licenca' => 'Renovação de LO', 'status' => 'DEFERIDO'],
            ['id' => 5, 'numero_pa' => '2026/0193-LIC', 'requerente' => 'Agropecuária Campos Verdes', 'tipo_licenca' => 'Licença Prévia (LP)', 'status' => 'EM ANÁLISE'],
        ];

        return response()->json($processos);
    }

    // Outros métodos da API (show, store, update, destroy) podem ser adicionados aqui.
}
