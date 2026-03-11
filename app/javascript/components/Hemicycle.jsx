import React, { useEffect, useRef } from 'react';
import * as d3 from 'd3';

const PARTY_COLORS = {
  'N-VA': '#FFED00',
  'CD&V': '#FF6200',
  'Open VLD': '#003D6D',
  'sp.a': '#FF0000',
  'Groen': '#00B050',
  'Vlaams Belang': '#FFE500',
  'PVDA': '#AA0000',
  'MR': '#0047AB',
  'PS': '#FF0000',
  'Ecolo': '#00B050',
  'cdH': '#FF6200',
  'DéFI': '#EC008C'
};

export default function Hemicycle({ politicians, onPoliticianClick }) {
  const svgRef = useRef();

  useEffect(() => {
    if (!politicians || politicians.length === 0) return;

    // Clear previous visualization
    d3.select(svgRef.current).selectAll('*').remove();

    const width = 1000;
    const height = 600;
    const centerX = width / 2;
    const centerY = height - 100;
    const radius = 400;

    const svg = d3.select(svgRef.current)
      .attr('width', width)
      .attr('height', height);

    // Create groups for convictions (each dot is a conviction)
    const allConvictions = [];
    politicians.forEach(politician => {
      politician.convictions.forEach(conviction => {
        allConvictions.push({
          ...conviction,
          politician: politician
        });
      });
    });

    // Sort by party and position
    const sortedConvictions = allConvictions.sort((a, b) => {
      return a.politician.party.localeCompare(b.politician.party);
    });

    // Calculate hemicycle positions
    const angleStep = Math.PI / (sortedConvictions.length + 1);

    const convictionsWithPositions = sortedConvictions.map((conviction, i) => {
      const angle = Math.PI - (angleStep * (i + 1));
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);

      return {
        ...conviction,
        x,
        y
      };
    });

    // Create tooltip
    const tooltip = d3.select('body')
      .append('div')
      .attr('class', 'tooltip')
      .style('position', 'absolute')
      .style('padding', '10px')
      .style('background', 'white')
      .style('border', '1px solid #ddd')
      .style('border-radius', '4px')
      .style('pointer-events', 'none')
      .style('opacity', 0);

    // Draw conviction dots
    svg.selectAll('circle')
      .data(convictionsWithPositions)
      .enter()
      .append('circle')
      .attr('cx', d => d.x)
      .attr('cy', d => d.y)
      .attr('r', 8)
      .attr('fill', d => PARTY_COLORS[d.politician.party] || '#999')
      .attr('stroke', '#333')
      .attr('stroke-width', 1)
      .attr('opacity', 0.8)
      .style('cursor', 'pointer')
      .on('mouseover', function(event, d) {
        d3.select(this)
          .attr('r', 12)
          .attr('opacity', 1);

        tooltip
          .style('opacity', 1)
          .html(`
            <strong>${d.politician.name}</strong><br/>
            Party: ${d.politician.party}<br/>
            Offense: ${d.offense_type}<br/>
            Date: ${d.conviction_date}<br/>
            ${d.sentence_prison ? `Prison: ${d.sentence_prison}<br/>` : ''}
            ${d.sentence_fine ? `Fine: €${d.sentence_fine}` : ''}
          `)
          .style('left', (event.pageX + 10) + 'px')
          .style('top', (event.pageY - 10) + 'px');
      })
      .on('mouseout', function() {
        d3.select(this)
          .attr('r', 8)
          .attr('opacity', 0.8);

        tooltip.style('opacity', 0);
      })
      .on('click', function(event, d) {
        onPoliticianClick(d.politician);
      });

    // Cleanup on unmount
    return () => {
      tooltip.remove();
    };
  }, [politicians, onPoliticianClick]);

  return (
    <div className="w-full h-full flex items-center justify-center">
      <svg ref={svgRef}></svg>
    </div>
  );
}
