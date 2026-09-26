'use client';

import { useEffect, useMemo, useState } from 'react';

type Mode = 'world' | 'lucid' | 'emotion';
type SceneView = 'daily' | 'lifetime' | 'recurring';
type Point = { x: number; y: number };
type SceneLocation = { id: string; label: string; x: number; y: number; kind: string; visits: number; detail: string };

const initialDream = `I was back at my old school. I found a mirror inside a door that shouldn't exist. When I looked into it, gravity disappeared and I started flying.`;

const lifetimeLocations: SceneLocation[] = [
  { id: 'flight', label: 'Flight Zone', x: 52, y: 13, kind: 'cloud', visits: 6, detail: 'A bright pocket above the rooftops where gravity lets go.' },
  { id: 'roof', label: 'Rooftop', x: 51, y: 28, kind: 'roof', visits: 3, detail: 'The last place before the world opens into the sky.' },
  { id: 'school', label: 'Old School', x: 38, y: 49, kind: 'school', visits: 7, detail: 'A familiar district with changing corridors and a warm nostalgia signal.' },
  { id: 'doors', label: 'Door Maze', x: 70, y: 48, kind: 'door', visits: 4, detail: 'A recurring sign: doors that lead somewhere the map has not named yet.' },
  { id: 'lake', label: 'Mirror Lake', x: 22, y: 68, kind: 'lake', visits: 5, detail: 'Still water, reflective surfaces, and a little unease.' },
  { id: 'forest', label: 'Memory Forest', x: 53, y: 75, kind: 'forest', visits: 3, detail: 'A softer route between home and the water.' },
  { id: 'home', label: 'Childhood Home', x: 78, y: 77, kind: 'home', visits: 6, detail: 'The first landmark in Maya\'s mapped world.' },
];

const dailyLocations: SceneLocation[] = [
  { id: 'daily-home', label: 'Childhood Home', x: 18, y: 75, kind: 'home', visits: 1, detail: 'The place where tonight’s dream began.' },
  { id: 'daily-school', label: 'Old School', x: 39, y: 52, kind: 'school', visits: 7, detail: 'The corridor returns exactly as you remember it.' },
  { id: 'daily-mirror', label: 'Mirror', x: 64, y: 45, kind: 'lake', visits: 1, detail: 'A mirror inside a door that should not exist.' },
  { id: 'daily-flight', label: 'Flight', x: 79, y: 20, kind: 'cloud', visits: 1, detail: 'Gravity disappears. The scene opens into sky.' },
];

const recurringLocations: SceneLocation[] = [
  { id: 'recurring-school', label: 'Old School', x: 35, y: 51, kind: 'school', visits: 7, detail: 'The anchor scene. Seven visits, five with the same corridor.' },
  { id: 'recurring-corridor', label: 'Changing Corridor', x: 53, y: 43, kind: 'door', visits: 6, detail: 'The hallway changes length each time the dream returns.' },
  { id: 'recurring-roof', label: 'Rooftop', x: 71, y: 30, kind: 'roof', visits: 5, detail: 'The recurring exit: roof, sky, flight.' },
  { id: 'recurring-flight', label: 'Flight', x: 78, y: 13, kind: 'cloud', visits: 5, detail: 'The most consistent ending across the recurring dream.' },
];

const dreamSigns = [
  { label: 'Impossible doors', score: 91, count: '7 appearances', lucid: '5 lucid-associated', color: 'violet' },
  { label: 'Flying', score: 84, count: '6 appearances', lucid: '5 lucid-associated', color: 'blue' },
  { label: 'Mirrors', score: 65, count: '5 appearances', lucid: '4 lucid-associated', color: 'cyan' },
];

const sceneMeta: Record<SceneView, { label: string; title: string; description: string; intro: string }> = {
  daily: { label: 'TONIGHT’S DREAM SCENE', title: 'Tonight, fully remembered.', description: 'One complete dream, from first image to last feeling.', intro: 'School. Mirror. Flight.' },
  lifetime: { label: 'MAYA’S LIFETIME DREAMSCAPE', title: 'The world keeps growing.', description: 'Every new dream adds another path to the same world.', intro: 'Every dream leaves a trace.' },
  recurring: { label: 'THE MOST RECURRING DREAM', title: 'One dream. Many returns.', description: 'The repeated version of your dreams, gathered in one scene.', intro: 'The school returns again.' },
};

function MapNode({ location, selected, onSelect, mode }: { location: SceneLocation; selected: boolean; onSelect: () => void; mode: Mode }) {
  const isSign = location.kind === 'door' || location.kind === 'lake' || location.kind === 'cloud';
  const glyph = location.kind === 'school' || location.kind === 'home' ? '⌂' : location.kind === 'forest' ? '♧' : location.kind === 'lake' ? '◒' : location.kind === 'door' ? '⌑' : location.kind === 'roof' ? '⌃' : '✦';
  return <button className={`map-node ${location.kind} ${selected ? 'selected' : ''} ${mode === 'lucid' && isSign ? 'lucid-highlight' : ''}`} style={{ left: `${location.x}%`, top: `${location.y}%` }} onClick={onSelect} aria-label={`Open ${location.label}`}>
    <span className="node-glyph">{glyph}</span><span className="node-label">{location.label}</span>{location.visits > 1 && <span className="node-visits">{location.visits} visits</span>}
  </button>;
}

export default function Home() {
  const [dream, setDream] = useState(initialDream);
  const [mapped, setMapped] = useState(false);
  const [mode, setMode] = useState<Mode>('world');
  const [view, setView] = useState<SceneView>('daily');
  const [selected, setSelected] = useState('daily-school');
  const [replaying, setReplaying] = useState(false);
  const [timeline, setTimeline] = useState(100);
  const [gameMode, setGameMode] = useState(false);
  const [intro, setIntro] = useState(false);
  const [memoryOpen, setMemoryOpen] = useState(false);
  const [player, setPlayer] = useState<Point>({ x: 18, y: 75 });
  const [trail, setTrail] = useState<Point[]>([{ x: 18, y: 75 }]);
  const [visited, setVisited] = useState<string[]>([]);
  const [chapter, setChapter] = useState('Tonight’s scene is still unfolding.');
  const [zoom, setZoom] = useState(100);

  const sceneLocations = useMemo(() => view === 'daily' ? dailyLocations : view === 'recurring' ? recurringLocations : lifetimeLocations, [view]);
  const selectedLocation = useMemo(() => sceneLocations.find((item) => item.id === selected) ?? sceneLocations[0], [sceneLocations, selected]);
  const nearbyLocation = useMemo(() => {
    const nearest = sceneLocations.map((location) => ({ location, distance: Math.hypot(player.x - location.x, player.y - location.y) })).sort((a, b) => a.distance - b.distance)[0];
    return nearest && nearest.distance < 9 ? nearest.location : null;
  }, [player, sceneLocations]);
  const meta = sceneMeta[view];

  function changeView(next: SceneView) {
    setView(next); setGameMode(false); setMemoryOpen(false); setSelected(next === 'daily' ? 'daily-school' : next === 'recurring' ? 'recurring-school' : 'school');
  }
  function mapDream() { changeView('daily'); setMapped(false); window.setTimeout(() => setMapped(true), 180); }
  function replay() { setReplaying(false); window.setTimeout(() => setReplaying(true), 80); window.setTimeout(() => setReplaying(false), 4100); }
  function enterDream() { const start = view === 'daily' ? { x: 18, y: 75 } : view === 'recurring' ? { x: 35, y: 51 } : { x: 63, y: 63 }; setGameMode(true); setMemoryOpen(false); setIntro(true); setPlayer(start); setTrail([start]); setVisited([]); setChapter(meta.intro); window.setTimeout(() => setIntro(false), 2300); }
  function openMemory(locationId: string) { setSelected(locationId); setMemoryOpen(true); }

  useEffect(() => {
    if (!gameMode) return;
    const move = (event: KeyboardEvent) => {
      if (event.key === 'Escape') { setGameMode(false); setMemoryOpen(false); return; }
      if (!['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'w', 'a', 's', 'd'].includes(event.key)) return;
      event.preventDefault();
      const step = event.shiftKey ? 4 : 2;
      const dx = event.key === 'ArrowRight' || event.key === 'd' ? step : event.key === 'ArrowLeft' || event.key === 'a' ? -step : 0;
      const dy = event.key === 'ArrowDown' || event.key === 's' ? step : event.key === 'ArrowUp' || event.key === 'w' ? -step : 0;
      setPlayer((current) => { const next = { x: Math.max(8, Math.min(92, current.x + dx)), y: Math.max(8, Math.min(90, current.y + dy)) }; setTrail((path) => [...path, next].slice(-32)); return next; });
    };
    window.addEventListener('keydown', move); return () => window.removeEventListener('keydown', move);
  }, [gameMode]);

  useEffect(() => {
    if (!nearbyLocation || visited.includes(nearbyLocation.id)) return;
    setSelected(nearbyLocation.id); setVisited((current) => [...current, nearbyLocation.id]);
    setChapter(nearbyLocation.kind === 'door' ? 'The door remembers a route you have not taken yet.' : nearbyLocation.kind === 'lake' ? 'Something in the water looks back.' : nearbyLocation.kind === 'cloud' ? 'Gravity is only a suggestion here.' : nearbyLocation.kind === 'school' ? 'You have been here before.' : `${nearbyLocation.label} has entered the story.`);
  }, [nearbyLocation, visited]);

  return <main className={`app-shell ${gameMode ? 'game-mode' : ''}`}>
    <header className="topbar"><div className="brand-lockup"><span className="brand-mark">✦</span><span>DreamScape</span><span className="beta-pill">BETA</span></div><div className="topnav"><button className={view === 'daily' ? 'nav-active' : ''} onClick={() => changeView('daily')}>Tonight</button><button className={view === 'lifetime' ? 'nav-active' : ''} onClick={() => changeView('lifetime')}>Lifetime world</button><button className={view === 'recurring' ? 'nav-active' : ''} onClick={() => changeView('recurring')}>Most recurring</button></div><div className="profile"><span className="status-dot" /> Maya <span className="profile-avatar">M</span></div></header>
    {gameMode && memoryOpen && <div className="memory-modal-backdrop" onClick={() => setMemoryOpen(false)}><article className="memory-modal" onClick={(event) => event.stopPropagation()}><div className="eyebrow">MEMORY ARCHIVE · {selectedLocation.visits} VISITS</div><button className="memory-close" aria-label="Close memory" onClick={() => setMemoryOpen(false)}>×</button><div className={`memory-icon ${selectedLocation.kind}`}>✦</div><h2>{selectedLocation.label}</h2><p className="memory-quote">“{selectedLocation.detail}”</p><div className="memory-rule" /><div className="memory-meta"><span>FIRST SEEN<strong>{view === 'daily' ? '26 SEP 2026' : '18 JUL 2026'}</strong></span><span>SCENE<strong>{view === 'daily' ? 'Tonight' : view === 'lifetime' ? 'Lifetime' : 'Recurring'}</strong></span></div><button className="memory-continue" onClick={() => setMemoryOpen(false)}>Continue exploring <span>→</span></button></article></div>}
    <section className="workspace">
      <aside className="journal-panel"><div className="eyebrow">Tonight’s memory</div><h1>Where did you go?</h1><p className="intro">Save a dream. DreamScape places it in tonight’s scene, your lifetime world, and any recurring dream it belongs to.</p><textarea value={dream} onChange={(event) => setDream(event.target.value)} aria-label="Dream memory" /><div className="journal-meta"><span>◷ 26 September 2026</span><button aria-label="Mark as lucid">✦ Lucid</button></div><button className="map-button" onClick={mapDream}><span>{mapped ? 'Tonight’s scene updated' : 'Save & build tonight'}</span><span>→</span></button><div className="processing-note"><span className="sparkle">✦</span><span>{mapped ? 'Scene saved · lifetime world expanded' : 'Your memories stay yours. No interpretations.'}</span></div><div className="panel-divider" /><div className="eyebrow">Three ways to see your dreams</div><div className="scene-list"><button className={view === 'daily' ? 'scene-list-active' : ''} onClick={() => changeView('daily')}><span>01</span><b>Tonight’s scene</b><small>One dream, fully made</small></button><button className={view === 'lifetime' ? 'scene-list-active' : ''} onClick={() => changeView('lifetime')}><span>02</span><b>Lifetime world</b><small>Every dream, one growing map</small></button><button className={view === 'recurring' ? 'scene-list-active' : ''} onClick={() => changeView('recurring')}><span>03</span><b>Most recurring</b><small>One dream, many returns</small></button></div><div className="panel-divider" /><div className="sidebar-footer"><span>10 dreams saved</span><span className="mini-orb">◌</span></div></aside>
      <section className="map-section"><div className="scene-intent"><span>{meta.label}</span><strong>{meta.title}</strong><em>{meta.description}</em></div><div className="map-toolbar"><div><div className="eyebrow">{meta.label}</div><h2>{gameMode ? 'Walk the world.' : meta.title}</h2></div><div className="map-actions">{!gameMode && <button className="enter-button" onClick={enterDream}>✦ Enter scene</button>}<button className={mode === 'world' ? 'active' : ''} onClick={() => setMode('world')}>◎ World</button><button className={mode === 'lucid' ? 'active' : ''} onClick={() => setMode('lucid')}>✦ Lucid view</button><button className={mode === 'emotion' ? 'active' : ''} onClick={() => setMode('emotion')}>◌ Emotion</button></div></div><div className={`dream-map ${view} ${mode} ${mapped ? 'map-updated' : ''} ${nearbyLocation ? `near-${nearbyLocation.kind}` : ''}`} style={{ '--zoom': `${zoom / 100}` } as React.CSSProperties}><div className="map-sky-label">{view === 'daily' ? 'ONE DREAM · 26 SEPTEMBER' : view === 'lifetime' ? 'THE PLACES BETWEEN SLEEP' : 'THE SCHOOL DREAM · 7 RETURNS'}</div>{gameMode && intro && <div className="dream-intro"><span>ENTERING SCENE</span><h2>{meta.intro}</h2><p>{meta.description}</p></div>}<div className="constellation constellation-a">·  ·  ✦  ·</div><div className="constellation constellation-b">✧  ·  ·  ·  ✦</div><div className="terrain terrain-north" /><div className="terrain terrain-west" /><div className="terrain terrain-east" /><div className="terrain terrain-south" /><svg className="map-routes" viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true"><path d={view === 'daily' ? 'M18 75 C25 68 32 58 39 52 C49 48 57 46 64 45 C71 36 75 26 79 20' : view === 'recurring' ? 'M35 51 C43 47 49 45 53 43 C62 38 67 33 71 30 C75 24 77 18 78 13' : 'M78 77 C68 70 65 58 70 48 C64 39 57 34 51 28 C51 23 51 18 52 13'} /><path d="M22 68 C26 59 29 55 38 49 C47 56 49 67 53 75" /><path d="M38 49 C46 45 60 46 70 48" />{trail.length > 1 && <polyline className="player-trail" points={trail.map((point) => `${point.x},${point.y}`).join(' ')} />}</svg><div className="route route-school">{view === 'daily' ? 'TONIGHT’S ROUTE' : view === 'recurring' ? 'RETURN ROUTE' : 'SCHOOL ROAD'} <span>→</span></div><div className="route route-water">{view === 'daily' ? 'NEW TONIGHT' : view === 'recurring' ? 'SEEN 5×' : 'DREAM RIVER'} <span>≈</span></div>{sceneLocations.map((location) => <MapNode key={location.id} location={location} selected={selected === location.id} onSelect={() => gameMode ? openMemory(location.id) : setSelected(location.id)} mode={mode} />)}<div className="you-marker"><span>★</span><small>YOU</small></div>{gameMode && <div className="player-avatar" style={{ left: `${player.x}%`, top: `${player.y}%` }} aria-label="Maya player">✦<small>MAYA</small></div>}{replaying && <div className="replay-avatar">✦</div>}<div className="fog fog-one" /><div className="fog fog-two" /><div className="map-compass">N<br /><span>✦</span></div>{gameMode && nearbyLocation && <div className="encounter-card"><div className="eyebrow">NEW MEMORY FOUND</div><strong>{nearbyLocation.label}</strong><p>{chapter}</p><button onClick={() => openMemory(nearbyLocation.id)}>Open memory ↗</button></div>}{gameMode && <div className="game-hud"><div><strong>IN SCENE <span className="chapter-count">{visited.length}/{sceneLocations.length} found</span></strong><span>{chapter}</span><small>WASD / ARROWS to move · SHIFT to move faster</small></div><button onClick={() => { setGameMode(false); setMemoryOpen(false); }}>Exit scene <span>Esc</span></button></div>}</div><div className="map-footer"><button className="replay-button" onClick={replay}>▶ Replay this scene</button><div className="timeline"><span>JUN</span><input aria-label="Dream timeline" type="range" min="0" max="100" value={timeline} onChange={(event) => setTimeline(Number(event.target.value))} /><span>SEP</span><b>{timeline === 100 ? 'Now' : `${Math.round(timeline / 25)} months ago`}</b></div><button className="zoom-button" aria-label="Map zoom controls" onClick={() => setZoom((current) => current === 100 ? 115 : 100)}>＋<span>{zoom}%</span>−</button></div></section>
      <aside className="insight-panel"><div className="selected-card"><div className="card-topline"><span className="eyebrow">{view === 'daily' ? 'TONIGHT’S MEMORY' : view === 'lifetime' ? 'YOU’VE BEEN HERE BEFORE' : 'RECURRING SCENE'}</span><button className="close-button" onClick={() => setSelected(sceneLocations[0].id)}>×</button></div><h3>{selectedLocation.label}</h3><p>{selectedLocation.detail}</p><div className="selected-stats"><div><strong>{selectedLocation.visits}</strong><span>{view === 'daily' ? 'tonight' : 'visits'}</span></div><div><strong>{view === 'recurring' ? '7' : '18'}<span className="small-unit"> {view === 'daily' ? 'Sep' : 'Jul'}</span></strong><span>first seen</span></div><div><strong>{view === 'daily' ? 'new' : view === 'recurring' ? 'school' : 'nostalgia'}</strong><span>{view === 'recurring' ? 'anchor' : 'mood'}</span></div></div><button className="history-link" onClick={() => gameMode ? openMemory(selectedLocation.id) : setSelected(selectedLocation.id)}>{view === 'recurring' ? 'Open recurring history' : 'Open location history'} <span>↗</span></button></div><div className="insight-block"><div className="block-heading"><div><div className="eyebrow">PATTERNS TO NOTICE</div><h3>{view === 'recurring' ? 'The repeated ingredients' : 'Your dream signs'}</h3></div><span className="info-icon">i</span></div><p className="block-copy">{view === 'daily' ? 'Tonight’s scene is one complete journey.' : view === 'recurring' ? 'What survives every return to this dream.' : 'Recurring anomalies from your own dreams — not interpretations.'}</p>{dreamSigns.map((sign) => <button className={`sign-row ${mode === 'lucid' ? 'sign-glow' : ''}`} key={sign.label} onClick={() => openMemory(view === 'daily' ? 'daily-mirror' : sign.label === 'Flying' ? (view === 'recurring' ? 'recurring-flight' : 'flight') : sign.label === 'Mirrors' ? 'lake' : view === 'recurring' ? 'recurring-corridor' : 'doors')}><div className="sign-head"><span>{sign.label}</span><strong>{view === 'recurring' && sign.label === 'Flying' ? '5/7' : sign.score}</strong></div><div className="score-track"><span className={sign.color} style={{ width: `${sign.score}%` }} /></div><div className="sign-foot"><span>{view === 'recurring' ? 'in the recurring scene' : sign.count}</span><span>{sign.lucid}</span></div></button>)}</div><div className="insight-block stats-block"><div className="eyebrow">{view === 'daily' ? 'TONIGHT' : view === 'recurring' ? 'RECURRING DREAM' : 'YOUR DREAM WORLD'}</div><div className="stat-grid"><div><strong>{view === 'daily' ? '4' : view === 'recurring' ? '7' : '10'}</strong><span>{view === 'daily' ? 'places tonight' : view === 'recurring' ? 'returns' : 'dreams mapped'}</span></div><div><strong>{view === 'daily' ? '1' : view === 'recurring' ? '1' : '17'}</strong><span>{view === 'daily' ? 'new sign' : view === 'recurring' ? 'anchor scene' : 'regions discovered'}</span></div><div><strong>{view === 'daily' ? '3' : view === 'recurring' ? '5' : '9'}</strong><span>{view === 'daily' ? 'familiar signs' : view === 'recurring' ? 'same endings' : 'recurring characters'}</span></div><div><strong>{view === 'daily' ? '26' : view === 'recurring' ? 'Sep' : '6'}</strong><span>{view === 'daily' ? 'Sep 2026' : view === 'recurring' ? 'last seen' : 'lucid dreams'}</span></div></div><div className="world-size"><span>Scene status</span><strong>{view === 'daily' ? 'Building tonight' : view === 'recurring' ? 'Most visited' : 'Growing continuously'}</strong></div></div><div className="quote-card"><span className="quote-mark">“</span><p>{view === 'daily' ? 'A dream is not a note. It is a place you can return to.' : view === 'recurring' ? 'The same dream is never exactly the same twice.' : 'Every dream changes the geography.'}</p><span className="quote-attribution">— DreamScape principle</span></div></aside>
    </section>
  </main>;
}
