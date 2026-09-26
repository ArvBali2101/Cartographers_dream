'use client';

import { useEffect, useMemo, useState } from 'react';

type Mode = 'world' | 'lucid' | 'emotion';
type Point = { x: number; y: number };
const initialDream = `I was back at my old school. I found a mirror inside a door that shouldn't exist. When I looked into it, gravity disappeared and I started flying.`;
const locations = [
  { id: 'flight', label: 'Flight Zone', x: 52, y: 13, kind: 'cloud', visits: 6, detail: 'A bright pocket above the rooftops where gravity lets go.' },
  { id: 'roof', label: 'Rooftop', x: 51, y: 28, kind: 'roof', visits: 3, detail: 'The last place before the world opens into the sky.' },
  { id: 'school', label: 'Old School', x: 38, y: 49, kind: 'school', visits: 7, detail: 'A familiar district with changing corridors and a warm nostalgia signal.' },
  { id: 'doors', label: 'Door Maze', x: 70, y: 48, kind: 'door', visits: 4, detail: 'A recurring sign: doors that lead somewhere the map has not named yet.' },
  { id: 'lake', label: 'Mirror Lake', x: 22, y: 68, kind: 'lake', visits: 5, detail: 'Still water, reflective surfaces, and a little unease.' },
  { id: 'forest', label: 'Memory Forest', x: 53, y: 75, kind: 'forest', visits: 3, detail: 'A softer route between home and the water.' },
  { id: 'home', label: 'Childhood Home', x: 78, y: 77, kind: 'home', visits: 6, detail: 'The first landmark in Maya\'s mapped world.' },
];
const dreamSigns = [
  { label: 'Impossible doors', score: 91, count: '7 appearances', lucid: '5 lucid-associated', color: 'violet' },
  { label: 'Flying', score: 84, count: '6 appearances', lucid: '5 lucid-associated', color: 'blue' },
  { label: 'Mirrors', score: 65, count: '5 appearances', lucid: '4 lucid-associated', color: 'cyan' },
];

function MapNode({ location, selected, onSelect, mode }: { location: (typeof locations)[number]; selected: boolean; onSelect: () => void; mode: Mode }) {
  const isSign = location.kind === 'door' || location.kind === 'lake' || location.kind === 'flight';
  return <button className={`map-node ${location.kind} ${selected ? 'selected' : ''} ${mode === 'lucid' && isSign ? 'lucid-highlight' : ''}`} style={{ left: `${location.x}%`, top: `${location.y}%` }} onClick={onSelect} aria-label={`Open ${location.label}`}>
    <span className="node-glyph">{location.kind === 'school' || location.kind === 'home' ? '⌂' : location.kind === 'forest' ? '♧' : location.kind === 'lake' ? '◒' : location.kind === 'door' ? '⌑' : location.kind === 'roof' ? '⌃' : '✦'}</span>
    <span className="node-label">{location.label}</span>{location.visits > 1 && <span className="node-visits">{location.visits} visits</span>}
  </button>;
}

export default function Home() {
  const [dream, setDream] = useState(initialDream); const [mapped, setMapped] = useState(false); const [mode, setMode] = useState<Mode>('world'); const [selected, setSelected] = useState('school'); const [replaying, setReplaying] = useState(false); const [timeline, setTimeline] = useState(100); const [gameMode, setGameMode] = useState(false); const [intro, setIntro] = useState(false); const [player, setPlayer] = useState<Point>({ x: 63, y: 63 }); const [trail, setTrail] = useState<Point[]>([{ x: 63, y: 63 }]); const [visited, setVisited] = useState<string[]>([]); const [chapter, setChapter] = useState('The school is waiting.'); const [zoom, setZoom] = useState(100);
  const selectedLocation = useMemo(() => locations.find((item) => item.id === selected) ?? locations[2], [selected]);
  const nearbyLocation = useMemo(() => {
    const nearby = locations.map((location) => ({ location, distance: Math.hypot(player.x - location.x, player.y - location.y) })).sort((a, b) => a.distance - b.distance)[0];
    return nearby && nearby.distance < 9 ? nearby.location : null;
  }, [player]);
  function mapDream() { setMapped(false); window.setTimeout(() => setMapped(true), 180); }
  function replay() { setReplaying(false); window.setTimeout(() => setReplaying(true), 80); window.setTimeout(() => setReplaying(false), 4100); }
  useEffect(() => {
    if (!gameMode) return;
    const move = (event: KeyboardEvent) => {
      if (event.key === 'Escape') { setGameMode(false); return; }
      if (!['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'w', 'a', 's', 'd'].includes(event.key)) return;
      event.preventDefault();
      const step = event.shiftKey ? 4 : 2;
      const dx = event.key === 'ArrowRight' || event.key === 'd' ? step : event.key === 'ArrowLeft' || event.key === 'a' ? -step : 0;
      const dy = event.key === 'ArrowDown' || event.key === 's' ? step : event.key === 'ArrowUp' || event.key === 'w' ? -step : 0;
      setPlayer((current) => {
        const next = { x: Math.max(8, Math.min(92, current.x + dx)), y: Math.max(8, Math.min(90, current.y + dy)) };
        setTrail((currentTrail) => [...currentTrail, next].slice(-32));
        return next;
      });
    };
    window.addEventListener('keydown', move);
    return () => window.removeEventListener('keydown', move);
  }, [gameMode]);
  useEffect(() => {
    if (!nearbyLocation || visited.includes(nearbyLocation.id)) return;
    setSelected(nearbyLocation.id);
    setVisited((current) => [...current, nearbyLocation.id]);
    setChapter(nearbyLocation.kind === 'door' ? 'The door remembers a route you have not taken yet.' : nearbyLocation.kind === 'lake' ? 'Something in the water looks back.' : nearbyLocation.kind === 'cloud' ? 'Gravity is only a suggestion here.' : nearbyLocation.kind === 'school' ? 'You have been here before.' : `${nearbyLocation.label} has entered the story.`);
  }, [nearbyLocation, visited]);
  function enterDream() { setGameMode(true); setIntro(true); setPlayer({ x: 63, y: 63 }); setTrail([{ x: 63, y: 63 }]); setVisited([]); setChapter('The school is waiting.'); window.setTimeout(() => setIntro(false), 2300); }
  return <main className={`app-shell ${gameMode ? 'game-mode' : ''}`}>
    <header className="topbar"><div className="brand-lockup"><span className="brand-mark">✦</span><span>DreamScape</span><span className="beta-pill">BETA</span></div><div className="topnav"><button className="nav-active">World</button><button>Dream journal</button><button>Insights</button></div><div className="profile"><span className="status-dot" /> Maya <span className="profile-avatar">M</span></div></header>
    <section className="workspace">
      <aside className="journal-panel"><div className="eyebrow">Tonight’s memory</div><h1>Where did you go?</h1><p className="intro">Add a dream and watch your world remember it.</p><textarea value={dream} onChange={(event) => setDream(event.target.value)} aria-label="Dream memory" /><div className="journal-meta"><span>◷ 26 September 2026</span><button aria-label="Mark as lucid">✦ Lucid</button></div><button className="map-button" onClick={mapDream}><span>{mapped ? 'World updated' : 'Map my dream'}</span><span>→</span></button><div className="processing-note"><span className="sparkle">✦</span><span>{mapped ? '3 familiar places found · 1 new sign' : 'Your memories stay yours. No interpretations.'}</span></div><div className="panel-divider" /><div className="eyebrow">Last mapped dream</div><div className="last-dream"><div className="last-dream-date">21 SEPT 2026 <span>•</span> PARTLY LUCID</div><p>“I followed the school corridor until the doors began to change. Then I found the roof.”</p><button onClick={() => setSelected('school')}>View journey <span>↗</span></button></div><div className="panel-divider" /><div className="sidebar-footer"><span>10 dreams mapped</span><span className="mini-orb">◌</span></div></aside>
      <section className="map-section"><div className="map-toolbar"><div><div className="eyebrow">MAYA’S DREAM WORLD</div><h2>{gameMode ? 'Walk the world.' : 'The world remembers.'}</h2></div><div className="map-actions">{!gameMode && <button className="enter-button" onClick={enterDream}>✦ Enter dream</button>}<button className={mode === 'world' ? 'active' : ''} onClick={() => setMode('world')}>◎ World</button><button className={mode === 'lucid' ? 'active' : ''} onClick={() => setMode('lucid')}>✦ Lucid view</button><button className={mode === 'emotion' ? 'active' : ''} onClick={() => setMode('emotion')}>◌ Emotion</button></div></div><div className={`dream-map ${mode} ${mapped ? 'map-updated' : ''} ${nearbyLocation ? `near-${nearbyLocation.kind}` : ''}`} style={{ '--zoom': `${zoom / 100}` } as React.CSSProperties}><div className="map-sky-label">THE PLACES BETWEEN SLEEP</div>{gameMode && intro && <div className="dream-intro"><span>LAST NIGHT</span><h2>School. Mirror. Flight.</h2><p>A place can remember you.</p></div>}<div className="constellation constellation-a">·  ·  ✦  ·</div><div className="constellation constellation-b">✧  ·  ·  ·  ✦</div><div className="terrain terrain-north" /><div className="terrain terrain-west" /><div className="terrain terrain-east" /><div className="terrain terrain-south" /><svg className="map-routes" viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true"><path d="M78 77 C68 70 65 58 70 48 C64 39 57 34 51 28 C51 23 51 18 52 13" /><path d="M22 68 C26 59 29 55 38 49 C47 56 49 67 53 75" /><path d="M38 49 C46 45 60 46 70 48" />{trail.length > 1 && <polyline className="player-trail" points={trail.map((point) => `${point.x},${point.y}`).join(' ')} />}</svg><div className="route route-school">SCHOOL ROAD <span>→</span></div><div className="route route-water">DREAM RIVER <span>≈</span></div>{locations.map((location) => <MapNode key={location.id} location={location} selected={selected === location.id} onSelect={() => setSelected(location.id)} mode={mode} />)}<div className="you-marker"><span>★</span><small>YOU</small></div><div className="player-avatar" style={{ left: `${player.x}%`, top: `${player.y}%` }} aria-label="Maya player">✦<small>MAYA</small></div>{replaying && <div className="replay-avatar">✦</div>}<div className="fog fog-one" /><div className="fog fog-two" /><div className="map-compass">N<br /><span>✦</span></div>{gameMode && nearbyLocation && <div className="encounter-card"><div className="eyebrow">NEW MEMORY FOUND</div><strong>{nearbyLocation.label}</strong><p>{chapter}</p><button onClick={() => setSelected(nearbyLocation.id)}>Open memory ↗</button></div>}{gameMode && <div className="game-hud"><div><strong>ENTERED DREAM <span className="chapter-count">{visited.length}/7 places found</span></strong><span>{chapter}</span><small>WASD / ARROWS to move · SHIFT to move faster</small></div><button onClick={() => setGameMode(false)}>Exit dream <span>Esc</span></button></div>}</div><div className="map-footer"><button className="replay-button" onClick={replay}>▶ Replay last journey</button><div className="timeline"><span>JUN</span><input aria-label="Dream timeline" type="range" min="0" max="100" value={timeline} onChange={(event) => setTimeline(Number(event.target.value))} /><span>SEP</span><b>{timeline === 100 ? 'Now' : `${Math.round(timeline / 25)} months ago`}</b></div><button className="zoom-button" aria-label="Map zoom controls" onClick={() => setZoom((current) => current === 100 ? 115 : 100)}>＋<span>{zoom}%</span>−</button></div></section>
      <aside className="insight-panel"><div className="selected-card"><div className="card-topline"><span className="eyebrow">YOU’VE BEEN HERE BEFORE</span><button className="close-button" onClick={() => setSelected('school')}>×</button></div><h3>{selectedLocation.label}</h3><p>{selectedLocation.detail}</p><div className="selected-stats"><div><strong>{selectedLocation.visits}</strong><span>visits</span></div><div><strong>18<span className="small-unit"> Jul</span></strong><span>first seen</span></div><div><strong>{selectedLocation.kind === 'school' ? 'nostalgia' : 'wonder'}</strong><span>mood</span></div></div><button className="history-link">Open location history <span>↗</span></button></div><div className="insight-block"><div className="block-heading"><div><div className="eyebrow">PATTERNS TO NOTICE</div><h3>Your dream signs</h3></div><span className="info-icon">i</span></div><p className="block-copy">Recurring anomalies from your own dreams — not interpretations.</p>{dreamSigns.map((sign) => <button className={`sign-row ${mode === 'lucid' ? 'sign-glow' : ''}`} key={sign.label} onClick={() => setSelected(sign.label === 'Flying' ? 'flight' : sign.label === 'Mirrors' ? 'lake' : 'doors')}><div className="sign-head"><span>{sign.label}</span><strong>{sign.score}</strong></div><div className="score-track"><span className={sign.color} style={{ width: `${sign.score}%` }} /></div><div className="sign-foot"><span>{sign.count}</span><span>{sign.lucid}</span></div></button>)}</div><div className="insight-block stats-block"><div className="eyebrow">YOUR DREAM WORLD</div><div className="stat-grid"><div><strong>10</strong><span>dreams mapped</span></div><div><strong>17</strong><span>regions discovered</span></div><div><strong>9</strong><span>recurring characters</span></div><div><strong>6</strong><span>lucid dreams</span></div></div><div className="world-size"><span>World size</span><strong>2.8 dream-km²</strong></div></div><div className="quote-card"><span className="quote-mark">“</span><p>We don’t interpret what your dreams mean. We map the patterns already there.</p><span className="quote-attribution">— DreamScape principle</span></div></aside>
    </section>
  </main>;
}
