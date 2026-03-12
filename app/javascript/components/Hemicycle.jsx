import React, { useEffect, useRef, useState } from 'react';
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

const GREY_COLOR = '#D1D5DB';

export default function Hemicycle({ politicians, onPoliticianClick }) {
  const svgRef = useRef();
  const containerRef = useRef();
  const [tooltip, setTooltip] = useState({ show: false, content: '', x: 0, y: 0 });

  useEffect(() => {
    if (!politicians || politicians.length === 0) return;
    if (!containerRef.current) return;

    // Clear previous visualization
    d3.select(svgRef.current).selectAll('*').remove();

    // Get container dimensions
    const rect = containerRef.current.getBoundingClientRect();
    const width = rect.width > 0 ? rect.width : 800;
    const height = Math.max(rect.height > 0 ? rect.height : 450, 400);

    const cx = width / 2;
    const cy = height * 0.95;
    const outerRadius = Math.min(width, height * 2) * 0.45;
    const minInnerRadiusFactor = 0.3;

    const svg = d3.select(svgRef.current)
      .attr('viewBox', `0 0 ${width} ${height}`)
      .attr('preserveAspectRatio', 'xMidYMid meet');

    // Define political spectrum order (left to right)
    const partyOrder = {
      'PVDA': 1,        // Far-left
      'PS': 2,          // Left
      'sp.a': 3,        // Left
      'Ecolo': 4,       // Center-left
      'Groen': 5,       // Center-left
      'DéFI': 6,        // Center-left
      'cdH': 7,         // Center
      'CD&V': 8,        // Center
      'MR': 9,          // Center-right
      'Open VLD': 10,   // Center-right
      'N-VA': 11,       // Right
      'Vlaams Belang': 12  // Far-right
    };

    // Sort politicians by political spectrum
    const sortedPoliticians = [...politicians].sort((a, b) => {
      const orderA = partyOrder[a.party] || 99;
      const orderB = partyOrder[b.party] || 99;
      return orderA - orderB;
    });

    // Extract years for time scale
    const allYears = sortedPoliticians.flatMap(p =>
      (p.convictions || []).map(c => new Date(c.conviction_date).getFullYear())
    ).filter(y => !isNaN(y));

    const minYear = allYears.length > 0 ? Math.min(...allYears) : 1985;
    const maxYear = allYears.length > 0 ? Math.max(...allYears) : 2030;

    // Year to radius scale
    const yearRadius = d3.scaleLinear()
      .domain([minYear, maxYear])
      .range([outerRadius * minInnerRadiusFactor, outerRadius]);

    // Draw background arc
    svg.append('path')
      .attr('d', d3.arc()
        .innerRadius(outerRadius * minInnerRadiusFactor)
        .outerRadius(outerRadius)
        .startAngle(-Math.PI / 2)
        .endAngle(Math.PI / 2))
      .attr('transform', `translate(${cx},${cy})`)
      .attr('fill', '#f4f7fb');

    // Draw year grid lines (every 5 years)
    const gridYears = [];
    for (let y = minYear - (minYear % 5) + 5; y <= maxYear; y += 5) {
      gridYears.push(y);
    }

    gridYears.forEach(y => {
      const r = yearRadius(y);
      const isDecade = y % 10 === 0;

      svg.append('path')
        .attr('d', d3.arc()
          .innerRadius(r)
          .outerRadius(r)
          .startAngle(-Math.PI / 2)
          .endAngle(Math.PI / 2))
        .attr('transform', `translate(${cx},${cy})`)
        .attr('fill', 'none')
        .attr('stroke', '#ddd')
        .attr('stroke-width', 0.5)
        .attr('stroke-dasharray', '3,4');

      // Add decade labels
      if (isDecade) {
        svg.append('text')
          .attr('x', cx - r)
          .attr('y', cy + 14)
          .attr('text-anchor', 'middle')
          .attr('font-size', '11px')
          .attr('fill', '#666')
          .attr('font-family', 'sans-serif')
          .text(y);

        svg.append('text')
          .attr('x', cx + r)
          .attr('y', cy + 14)
          .attr('text-anchor', 'middle')
          .attr('font-size', '11px')
          .attr('fill', '#666')
          .attr('font-family', 'sans-serif')
          .text(y);
      }
    });

    // Draw outer border
    svg.append('path')
      .attr('d', d3.arc()
        .innerRadius(outerRadius * minInnerRadiusFactor)
        .outerRadius(outerRadius)
        .startAngle(-Math.PI / 2)
        .endAngle(Math.PI / 2))
      .attr('transform', `translate(${cx},${cy})`)
      .attr('fill', 'none')
      .attr('stroke', '#aaa')
      .attr('stroke-width', 1.5);

    // Calculate severity and prepare nodes
    const scoreToR = d3.scaleSqrt()
      .domain([0, 5])
      .range([5, 20]);

    const nodes = sortedPoliticians.map((politician, i) => {
      // Calculate total severity from convictions
      let totalYears = 0;
      let avgYear = minYear;

      if (politician.convictions && politician.convictions.length > 0) {
        const years = [];
        politician.convictions.forEach(conviction => {
          const convYear = new Date(conviction.conviction_date).getFullYear();
          if (!isNaN(convYear)) years.push(convYear);

          if (conviction.sentence_prison) {
            const match = conviction.sentence_prison.match(/(\d+)/);
            if (match) {
              totalYears += parseInt(match[1]);
            }
          }
        });
        if (years.length > 0) {
          avgYear = years.reduce((a, b) => a + b, 0) / years.length;
        }
      }

      const hasConvictions = politician.convictions && politician.convictions.length > 0;

      // Calculate position in hemicycle
      const partyPos = partyOrder[politician.party] || 6.5;
      // Map party position (1-12) to angle (-90° to +90°)
      const position = (partyPos - 1) / 11 * 2 - 1; // Convert to -1 to 1
      const angleDeg = position * 90;
      const angle = angleDeg * Math.PI / 180;
      const targetRadius = hasConvictions ? yearRadius(avgYear) : outerRadius * 0.15;

      return {
        ...politician,
        id: i,
        r: hasConvictions ? scoreToR(totalYears) : 6,
        score: totalYears,
        year: avgYear,
        hasConvictions,
        color: hasConvictions ? (PARTY_COLORS[politician.party] || '#999') : GREY_COLOR,
        tx: cx + Math.sin(angle) * targetRadius,
        ty: cy - Math.cos(angle) * targetRadius,
        x: cx + Math.sin(angle) * targetRadius,
        y: cy - Math.cos(angle) * targetRadius
      };
    });

    // Force simulation to prevent overlap
    const simulation = d3.forceSimulation(nodes)
      .force('collide', d3.forceCollide().radius(d => d.r + 1))
      .force('x', d3.forceX(d => d.tx).strength(0.2))
      .force('y', d3.forceY(d => d.ty).strength(0.2))
      .stop();

    // Run simulation
    for (let i = 0; i < 300; i++) {
      simulation.tick();

      // Clamp nodes to hemicycle
      nodes.forEach(d => {
        const dx = d.x - cx;
        const dy = cy - d.y;
        let radius = Math.sqrt(dx * dx + dy * dy);
        let theta = Math.atan2(dx, dy);
        const maxRadius = (d.hasConvictions ? outerRadius : outerRadius * minInnerRadiusFactor) - d.r - 1;

        radius = Math.min(radius, maxRadius);
        theta = Math.max(-Math.PI / 2, Math.min(Math.PI / 2, theta));

        d.x = cx + Math.sin(theta) * radius;
        d.y = cy - Math.cos(theta) * radius;

        if (d.y > cy - d.r) d.y = cy - d.r;
      });
    }

    // Draw nodes
    const circles = svg.selectAll('circle.node')
      .data(nodes)
      .enter()
      .append('circle')
      .attr('class', 'node')
      .attr('cx', d => d.x)
      .attr('cy', d => d.y)
      .attr('r', d => d.r)
      .attr('fill', d => d.color)
      .attr('stroke', '#333')
      .attr('stroke-width', 0.5)
      .attr('opacity', 0.85)
      .style('cursor', d => d.hasConvictions ? 'pointer' : 'default')
      .style('transition', 'opacity 0.15s')
      .on('mouseover', function(event, d) {
        d3.select(this)
          .attr('opacity', 1)
          .attr('stroke-width', 1.5);
      })
      .on('mouseout', function(event, d) {
        d3.select(this)
          .attr('opacity', 0.85)
          .attr('stroke-width', 0.5);
      })
      .on('click', function(event, d) {
        if (d.hasConvictions) {
          onPoliticianClick(d);
        }
      });

    // Add tooltips
    circles.append('title')
      .text(d => {
        let text = `${d.name}\n${d.party}`;
        if (d.hasConvictions) {
          text += `\n${d.convictions.length} condamnation(s)`;
          if (d.score > 0) {
            text += `\n${d.score} an(s) de prison`;
          }
        } else {
          text += '\nAucune condamnation';
        }
        return text;
      });

    // Draw size legend
    const sizeLegendData = [
      { score: 1, label: '1 an' },
      { score: 3, label: '3 ans' },
      { score: 5, label: '5 ans' }
    ];

    const legendSize = svg.append('g')
      .attr('class', 'legend-size')
      .attr('transform', `translate(${width - 140}, 24)`);

    let yOffset = 0;
    sizeLegendData.forEach(item => {
      const r = scoreToR(item.score);
      const y = yOffset + r;
      yOffset += 2 * r + 6;

      legendSize.append('text')
        .attr('x', 100 - r - 6)
        .attr('y', y + 4)
        .attr('text-anchor', 'end')
        .attr('font-size', '12px')
        .attr('fill', '#333')
        .attr('font-family', 'sans-serif')
        .text(item.label);

      legendSize.append('circle')
        .attr('cx', 100)
        .attr('cy', y)
        .attr('r', r)
        .attr('fill', '#555')
        .attr('stroke', '#333')
        .attr('stroke-width', 0.5);
    });

  }, [politicians, onPoliticianClick]);

  return (
    <div ref={containerRef} style={{ width: '100%', height: '100%', minHeight: '400px' }}>
      <svg ref={svgRef} style={{ width: '100%', height: '100%' }}></svg>
    </div>
  );
}
