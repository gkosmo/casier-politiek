import React from 'react';

const PARTY_COLORS = {
  'PVDA': '#AA0000',
  'PS': '#FF0000',
  'sp.a': '#FF0000',
  'Ecolo': '#00B050',
  'Groen': '#00B050',
  'DéFI': '#EC008C',
  'cdH': '#FF6200',
  'CD&V': '#FF6200',
  'MR': '#0047AB',
  'Open VLD': '#003D6D',
  'N-VA': '#FFED00',
  'Vlaams Belang': '#FFE500'
};

const PARTY_SPECTRUM = [
  { name: 'PVDA', label: 'PVDA', ideology: 'Extrême gauche' },
  { name: 'PS', label: 'PS', ideology: 'Gauche' },
  { name: 'sp.a', label: 'sp.a', ideology: 'Gauche' },
  { name: 'Ecolo', label: 'Ecolo', ideology: 'Centre-gauche' },
  { name: 'Groen', label: 'Groen', ideology: 'Centre-gauche' },
  { name: 'DéFI', label: 'DéFI', ideology: 'Centre-gauche' },
  { name: 'cdH', label: 'cdH', ideology: 'Centre' },
  { name: 'CD&V', label: 'CD&V', ideology: 'Centre' },
  { name: 'MR', label: 'MR', ideology: 'Centre-droit' },
  { name: 'Open VLD', label: 'Open VLD', ideology: 'Centre-droit' },
  { name: 'N-VA', label: 'N-VA', ideology: 'Droite' },
  { name: 'Vlaams Belang', label: 'Vlaams Belang', ideology: 'Extrême droite' }
];

export default function PartyLegend({ stats }) {
  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-6">
      <h3 className="text-xl font-bold mb-4 text-gray-800">Légende des partis</h3>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {PARTY_SPECTRUM.map(party => (
          <div key={party.name} className="flex items-center space-x-3">
            <div
              className="w-6 h-6 rounded-full border-2 border-gray-800 flex-shrink-0"
              style={{ backgroundColor: PARTY_COLORS[party.name] }}
            ></div>
            <div className="min-w-0">
              <div className="font-semibold text-sm text-gray-800 truncate">
                {party.label}
              </div>
              <div className="text-xs text-gray-500 truncate">
                {party.ideology}
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-6 pt-4 border-t border-gray-200">
        <div className="flex items-center space-x-3">
          <div className="w-6 h-6 rounded-full bg-gray-300 border-2 border-gray-800 flex-shrink-0"></div>
          <div>
            <div className="font-semibold text-sm text-gray-800">Sans condamnation</div>
            <div className="text-xs text-gray-500">Aucune condamnation connue</div>
          </div>
        </div>
      </div>
    </div>
  );
}
