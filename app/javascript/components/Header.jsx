import React from 'react';

export default function Header() {
  return (
    <header className="bg-gradient-to-r from-blue-900 to-blue-700 text-white shadow-lg">
      <div className="container mx-auto px-6 py-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-4xl font-bold mb-2">Casier Politique Belgique</h1>
            <p className="text-blue-200 text-lg">
              Transparence sur les condamnations des élus belges
            </p>
          </div>
          <div className="text-right">
            <div className="text-sm text-blue-200 mb-1">Dernière mise à jour</div>
            <div className="text-xl font-semibold">{new Date().toLocaleDateString('fr-BE')}</div>
          </div>
        </div>
      </div>
    </header>
  );
}
