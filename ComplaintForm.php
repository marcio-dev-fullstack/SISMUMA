<?php

namespace App\Livewire;

use Livewire\Component;
use Livewire\WithFileUploads;
use Livewire\Attributes\Rule;

class ComplaintForm extends Component
{
    use WithFileUploads;

    #[Rule('required|min:20', as: 'Descrição da Denúncia')]
    public $description = '';

    #[Rule('required|min:10', as: 'Localização')]
    public $location = '';

    #[Rule('nullable|image|max:2048', as: 'Foto')]
    public $photo;

    public $is_anonymous = true;

    #[Rule('required_if:is_anonymous,false|min:3', as: 'Seu Nome')]
    public $reporter_name = '';

    #[Rule('required_if:is_anonymous,false|email', as: 'Seu E-mail')]
    public $reporter_email = '';

    /**
     * Processa o envio do formulário de denúncia.
     */
    public function submit()
    {
        $this->validate();

        // Placeholder: Lógica para salvar a denúncia e a foto no banco de dados.
        // Ex:
        // O método store() agora usará o disco padrão (s3) definido no .env
        // $path = $this->photo ? $this->photo->store('complaints-evidence', 's3') : null;
        // Denuncia::create([
        //     'descricao' => $this->description,
        //     'localizacao' => $this->location,
        //     'foto_path' => $path,
        //     'anonima' => $this->is_anonymous,
        //     'nome_denunciante' => $this->is_anonymous ? null : $this->reporter_name,
        //     'email_denunciante' => $this->is_anonymous ? null : $this->reporter_email,
        //     'status' => 'recebida',
        // ]);

        session()->flash('message', 'Denúncia registrada com sucesso! Agradecemos sua colaboração.');
        $this->reset();
    }

    public function render()
    {
        return view('livewire.complaint-form');
    }
}