import React, { useState, useEffect } from "react";

export default function DashboardLicenciamento() {
  const [processos, setProcessos] = useState([]);

  useEffect(() => {
    fetch("/api/processos")
      .then((res) => res.json())
      .then((data) => setProcessos(data));
  }, []);

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <h1 className="text-2xl font-bold text-emerald-800 mb-4">
        Gestão de Licenciamento Ambiental (SISMUMA)
      </h1>
      <div className="bg-white shadow-md rounded-lg overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-emerald-700 text-white">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium uppercase">
                Nº Processo (PA)
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium uppercase">
                Requerente
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium uppercase">
                Tipo
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium uppercase">
                Status
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium uppercase">
                Ações
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {processos.map((proc) => (
              <tr key={proc.id}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {proc.numero_pa}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {proc.requerente}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {proc.tipo_licenca}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span
                    className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      proc.status === "DEFERIDO"
                        ? "bg-green-100 text-green-800"
                        : "bg-amber-100 text-amber-800"
                    }`}
                  >
                    {proc.status}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <a
                    href={`/pdf/termo-compromisso/${proc.id}`}
                    className="text-indigo-600 hover:text-indigo-900 mr-3"
                  >
                    Gerar Notificação
                  </a>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
