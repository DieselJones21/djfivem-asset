(function () {
  const app = document.getElementById('app');
  const shell = document.getElementById('shell');
  const gate = document.getElementById('gate');
  const adult = document.getElementById('adult');
  const requestEl = document.getElementById('request');
  const scenebar = document.getElementById('scenebar');
  const grid = document.getElementById('grid');
  const catsEl = document.getElementById('cats');
  const partnerBtn = document.getElementById('partner-btn');
  const partnerList = document.getElementById('partner-list');
  const searchEl = document.getElementById('search');
  const toasts = document.getElementById('toasts');

  const DEMO_POSES = [
    { id: 'kiss', label: 'Kiss', category: 'intimate', type: 'synced', place: 'world' },
    { id: 'kiss_close', label: 'Close Kiss', category: 'intimate', type: 'synced', place: 'world' },
    { id: 'hug', label: 'Hug', category: 'intimate', type: 'synced', place: 'world' },
    { id: 'blow_kiss', label: 'Blow Kiss', category: 'intimate', type: 'solo', place: 'world' },
    { id: 'slow_grind_stand', label: 'Close Grind', category: 'intimate', type: 'synced', place: 'world' },
    { id: 'standing_sex', label: 'Standing', category: 'standing', type: 'synced', place: 'world' },
    { id: 'standing_sex_alt', label: 'Standing (Deep)', category: 'standing', type: 'synced', place: 'world' },
    { id: 'pimp_sex', label: 'Bent Over', category: 'standing', type: 'synced', place: 'world' },
    { id: 'lap_dance', label: 'Lap Dance', category: 'seated', type: 'synced', place: 'world' },
    { id: 'lap_dance_p2', label: 'Lap Dance II', category: 'seated', type: 'synced', place: 'world' },
    { id: 'sit_straddle', label: 'Straddle', category: 'seated', type: 'synced', place: 'world' },
    { id: 'love_bear', label: 'On the Floor', category: 'lying', type: 'solo', place: 'world' },
    { id: 'sleep_cuddle', label: 'Sleepy Cuddle', category: 'lying', type: 'solo', place: 'world' },
    { id: 'sunbathe', label: 'Laid Out', category: 'lying', type: 'solo', place: 'world' },
    { id: 'car_bj', label: 'Car — Oral', category: 'oral', type: 'synced', place: 'vehicle' },
    { id: 'car_bj_low', label: 'Low Car — Oral', category: 'oral', type: 'synced', place: 'vehicle' },
    { id: 'car_sex', label: 'Car — Sex', category: 'vehicle', type: 'synced', place: 'vehicle' },
    { id: 'car_sex_low', label: 'Low Car — Sex', category: 'vehicle', type: 'synced', place: 'vehicle' },
    { id: 'front_seat', label: 'Front Seat', category: 'vehicle', type: 'synced', place: 'vehicle' },
    { id: 'private_dance_1', label: 'Private Dance I', category: 'tease', type: 'solo', place: 'world' },
    { id: 'private_dance_2', label: 'Private Dance II', category: 'tease', type: 'solo', place: 'world' },
    { id: 'pole_1', label: 'Pole Dance I', category: 'tease', type: 'solo', place: 'world' },
    { id: 'pole_2', label: 'Pole Dance II', category: 'tease', type: 'solo', place: 'world' },
    { id: 'strip_idle', label: 'Slow Idle', category: 'tease', type: 'solo', place: 'world' },
    { id: 'wall_sex', label: 'Against the Wall', category: 'rough', type: 'synced', place: 'world' },
    { id: 'standing_fast', label: 'Standing (Fast)', category: 'rough', type: 'synced', place: 'world' },
  ];

  const DEMO_CATS = [
    { id: 'intimate', label: 'Intimate', hint: 'Kiss, hold, close' },
    { id: 'standing', label: 'Standing', hint: 'Upright scenes' },
    { id: 'seated', label: 'Seated', hint: 'Chairs, laps, edges' },
    { id: 'lying', label: 'Lying', hint: 'Bed and floor' },
    { id: 'oral', label: 'Oral', hint: 'Kneeling and vehicle' },
    { id: 'vehicle', label: 'Vehicle', hint: 'Cars and trucks' },
    { id: 'tease', label: 'Tease', hint: 'Strip and dance' },
    { id: 'rough', label: 'Rough', hint: 'Against the wall' },
  ];

  const GLOWS = {
    intimate: 'rgba(224,139,150,.45)',
    standing: 'rgba(201,160,108,.4)',
    seated: 'rgba(156,120,180,.4)',
    lying: 'rgba(120,150,196,.4)',
    oral: 'rgba(196,92,106,.5)',
    vehicle: 'rgba(90,140,160,.45)',
    tease: 'rgba(220,170,110,.45)',
    rough: 'rgba(180,70,80,.5)',
  };

  const state = {
    open: false,
    allowed: false,
    adultOk: false,
    adultRequired: true,
    category: 'all',
    query: '',
    poses: [],
    categories: [],
    nearby: [],
    targetId: '',
    scene: { active: false, poseId: null, speed: 1, role: '' },
    request: null,
  };

  function inNui() {
    try {
      return typeof GetParentResourceName === 'function';
    } catch (e) {
      return false;
    }
  }

  function resourceName() {
    try {
      return GetParentResourceName();
    } catch (e) {
      return 'dj_nocturne';
    }
  }

  function post(name, data) {
    if (!inNui()) {
      return Promise.resolve({ ok: true, demo: true });
    }
    return fetch('https://' + resourceName() + '/' + name, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data || {}),
    }).then(function (r) { return r.json(); }).catch(function () { return {}; });
  }

  function toast(message) {
    if (!message) return;
    const el = document.createElement('div');
    el.className = 'toast';
    el.textContent = message;
    toasts.appendChild(el);
    setTimeout(function () { el.remove(); }, 3200);
  }

  function show(el, on) {
    el.classList.toggle('hidden', !on);
  }

  function applyAccess(access) {
    if (!access) return;
    state.allowed = !!access.allowed;
    state.adultRequired = access.adultConfirm !== false;
    state.categories = access.categories && access.categories.length ? access.categories : DEMO_CATS;
    state.poses = access.poses && access.poses.length ? access.poses : DEMO_POSES;

    if (access.ui) {
      document.getElementById('brand-name').textContent = access.ui.Brand || 'Nocturne';
      document.getElementById('brand-tag').textContent = access.ui.Tagline || 'Private rooms';
    }
    if (access.store) {
      document.getElementById('gate-product').textContent = access.store.ProductName || 'Nocturne Membership';
      document.getElementById('gate-price').textContent = access.store.PriceLabel || '$12.99';
      document.getElementById('gate-buy').href = access.store.TebexUrl || '#';
      document.getElementById('gate-discord').href = access.store.DiscordInvite || '#';
      const reasons = {
        discord_missing: 'FiveM is not linked to Discord. Link it in the FiveM settings, then rejoin.',
        not_in_guild: 'Join the Discord server, then hit sync.',
        no_role: 'Your paid role is not on this Discord account yet.',
        pending: 'Checking membership…',
      };
      document.getElementById('gate-reason').textContent = reasons[access.reason] || '';
    }
  }

  function renderCats() {
    const items = [{ id: 'all', label: 'All scenes', hint: 'Solo or send a request' }].concat(state.categories);
    catsEl.innerHTML = '';
    items.forEach(function (cat) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'cat' + (state.category === cat.id ? ' active' : '');
      btn.textContent = cat.label;
      btn.addEventListener('click', function () {
        state.category = cat.id;
        document.getElementById('cat-title').textContent = cat.label;
        document.getElementById('cat-hint').textContent = cat.hint || '';
        renderCats();
        renderGrid();
      });
      catsEl.appendChild(btn);
    });
  }

  function renderGrid() {
    const q = state.query.trim().toLowerCase();
    const list = state.poses.filter(function (p) {
      if (state.category !== 'all' && p.category !== state.category) return false;
      if (!q) return true;
      return (p.label + ' ' + p.category + ' ' + p.type).toLowerCase().indexOf(q) !== -1;
    });
    grid.innerHTML = '';
    if (!list.length) {
      const empty = document.createElement('div');
      empty.className = 'empty';
      empty.textContent = 'No poses in this room.';
      grid.appendChild(empty);
      return;
    }
    list.forEach(function (pose) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'pose';
      btn.style.setProperty('--glow', GLOWS[pose.category] || GLOWS.intimate);
      btn.innerHTML =
        '<span class="kind">' + (pose.type === 'solo' ? 'Solo' : 'Duet') + '</span>' +
        '<h3>' + pose.label + '</h3>' +
        '<span class="place">' + (pose.place === 'vehicle' ? 'Vehicle' : 'World') + '</span>';
      btn.addEventListener('click', function () {
        if (pose.type === 'synced' && !state.targetId) {
          toast('Pick a nearby partner first.');
          return;
        }
        post('play', { poseId: pose.id, targetId: state.targetId ? Number(state.targetId) : null });
        if (!inNui()) {
          state.scene = { active: true, poseId: pose.id, speed: 1, role: pose.type === 'solo' ? 'requester' : 'requester' };
          document.getElementById('scene-label').textContent = pose.label;
          document.getElementById('scene-role').textContent = pose.type === 'solo' ? 'solo' : 'waiting / lead';
          show(scenebar, true);
          toast(pose.type === 'solo' ? 'Playing ' + pose.label : 'Request sent for ' + pose.label);
        }
      });
      grid.appendChild(btn);
    });
  }

  function partnerLabel() {
    if (!state.targetId) return 'Nearby players';
    const p = state.nearby.find(function (n) { return String(n.id) === String(state.targetId); });
    return p ? p.name : 'Nearby players';
  }

  function renderNearby(players) {
    state.nearby = players || [];
    partnerBtn.textContent = partnerLabel();
    partnerList.innerHTML = '';
    const clear = document.createElement('button');
    clear.type = 'button';
    clear.className = 'partner-item' + (!state.targetId ? ' active' : '');
    clear.innerHTML = '<span>No partner</span><small>solo</small>';
    clear.addEventListener('click', function () {
      state.targetId = '';
      partnerBtn.textContent = 'Nearby players';
      partnerList.classList.add('hidden');
      renderNearby(state.nearby);
    });
    partnerList.appendChild(clear);
    if (!state.nearby.length) {
      const empty = document.createElement('div');
      empty.className = 'partner-item';
      empty.textContent = 'Nobody in range';
      partnerList.appendChild(empty);
      return;
    }
    state.nearby.forEach(function (p) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'partner-item' + (String(state.targetId) === String(p.id) ? ' active' : '');
      btn.innerHTML = '<span>' + p.name + '</span><small>' + p.distance + 'm' + (p.sameVehicle ? ' · car' : '') + '</small>';
      btn.addEventListener('click', function () {
        state.targetId = String(p.id);
        partnerBtn.textContent = p.name;
        partnerList.classList.add('hidden');
        renderNearby(state.nearby);
      });
      partnerList.appendChild(btn);
    });
  }

  function layout() {
    const showAdult = state.open && state.adultRequired && !state.adultOk;
    const showGate = state.open && !showAdult && !state.allowed;
    const showShell = state.open && !showAdult && state.allowed;
    show(app, state.open);
    app.setAttribute('aria-hidden', state.open ? 'false' : 'true');
    show(adult, showAdult);
    show(gate, showGate);
    show(shell, showShell);
    show(scenebar, state.open && state.scene.active);
    if (showShell) {
      renderCats();
      renderGrid();
    }
  }

  function openMenu(payload) {
    state.open = true;
    if (payload && payload.access) applyAccess(payload.access);
    if (payload && payload.nearby) renderNearby(payload.nearby);
    if (payload && payload.scene) {
      state.scene = payload.scene;
      if (payload.scene.poseId) {
        const pose = state.poses.find(function (p) { return p.id === payload.scene.poseId; });
        document.getElementById('scene-label').textContent = pose ? pose.label : 'In scene';
        document.getElementById('scene-role').textContent = payload.scene.role || '';
        document.getElementById('speed').value = payload.scene.speed || 1;
      }
    }
    layout();
  }

  function closeMenu() {
    state.open = false;
    layout();
    show(requestEl, false);
    post('close', {});
  }

  document.getElementById('adult-yes').addEventListener('click', function () {
    state.adultOk = true;
    layout();
  });
  document.getElementById('adult-no').addEventListener('click', closeMenu);
  document.getElementById('btn-close').addEventListener('click', closeMenu);
  document.getElementById('gate-sync').addEventListener('click', function () {
    post('resync', {});
    toast('Syncing Discord roles…');
  });
  document.getElementById('btn-resync').addEventListener('click', function () {
    post('resync', {});
    toast('Syncing Discord roles…');
  });
  document.getElementById('btn-stop').addEventListener('click', function () {
    post('stop', {});
    state.scene.active = false;
    show(scenebar, false);
  });
  document.getElementById('speed').addEventListener('input', function (e) {
    post('speed', { speed: Number(e.target.value) });
  });
  document.getElementById('btn-copy').addEventListener('click', function () {
    post('copyOffset', {}).then(function (res) {
      const text = (res && res.text) || '{ bone = 0, x = 0.000, y = 0.000, z = 0.000, rx = 0.000, ry = 0.000, rz = 0.000 }';
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text);
      }
      toast('Offset copied.');
    });
  });
  document.getElementById('nudge-pad').addEventListener('click', function (e) {
    const btn = e.target.closest('button');
    if (!btn) return;
    const spec = btn.getAttribute('data-nudge').split(':');
    const axis = spec[0];
    const amount = Number(spec[1]);
    const payload = { dx: 0, dy: 0, dz: 0, drx: 0, dry: 0, drz: 0 };
    payload['d' + axis] = amount;
    post('nudge', payload);
  });
  searchEl.addEventListener('input', function (e) {
    state.query = e.target.value;
    renderGrid();
  });
  partnerBtn.addEventListener('click', function (e) {
    e.stopPropagation();
    partnerList.classList.toggle('hidden');
  });
  document.addEventListener('click', function () {
    partnerList.classList.add('hidden');
  });
  partnerList.addEventListener('click', function (e) {
    e.stopPropagation();
  });
  document.getElementById('request-accept').addEventListener('click', function () {
    post('respond', { accepted: true });
    show(requestEl, false);
  });
  document.getElementById('request-deny').addEventListener('click', function () {
    post('respond', { accepted: false });
    show(requestEl, false);
  });

  window.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && state.open) {
      closeMenu();
    }
  });

  window.addEventListener('message', function (event) {
    const data = event.data || {};
    if (data.action === 'open') openMenu(data);
    if (data.action === 'close') {
      state.open = false;
      layout();
    }
    if (data.action === 'access') {
      applyAccess(data.access);
      layout();
    }
    if (data.action === 'nearby') renderNearby(data.players || []);
    if (data.action === 'toast') toast(data.message);
    if (data.action === 'scene') {
      state.scene.active = !!data.active;
      state.scene.poseId = data.poseId;
      state.scene.role = data.role;
      if (data.poseId) {
        const pose = state.poses.find(function (p) { return p.id === data.poseId; });
        document.getElementById('scene-label').textContent = pose ? pose.label : 'In scene';
        document.getElementById('scene-role').textContent = data.role || '';
      }
      show(scenebar, state.open && state.scene.active);
    }
    if (data.action === 'request') {
      state.request = data.request;
      document.getElementById('request-title').textContent = data.request.fromName + ' wants you';
      document.getElementById('request-copy').textContent = 'Pose: ' + data.request.poseLabel;
      const bar = document.getElementById('request-bar');
      bar.style.animationDuration = (data.request.timeout || 20) + 's';
      bar.style.animation = 'none';
      void bar.offsetWidth;
      bar.style.animation = 'drain ' + (data.request.timeout || 20) + 's linear forwards';
      show(app, true);
      show(requestEl, true);
    }
    if (data.action === 'speed') {
      document.getElementById('speed').value = data.speed;
    }
  });

  // Browser / screenshot demo
  if (!inNui()) {
    const params = new URLSearchParams(location.search);
    const locked = params.get('demo') === 'locked';
    applyAccess({
      allowed: !locked,
      reason: locked ? 'no_role' : 'open',
      adultConfirm: params.get('adult') !== '0',
      categories: DEMO_CATS,
      poses: DEMO_POSES,
      ui: { Brand: 'Nocturne', Tagline: 'Private rooms' },
      store: {
        ProductName: 'Nocturne Membership',
        PriceLabel: '$12.99',
        TebexUrl: 'https://your-store.tebex.io/package/nocturne',
        DiscordInvite: 'https://discord.gg/yourserver',
      },
    });
    renderNearby([
      { id: 12, name: 'Maya R.', distance: 1.2, sameVehicle: false },
      { id: 4, name: 'Julian V.', distance: 2.4, sameVehicle: false },
      { id: 27, name: 'Noel K.', distance: 3.1, sameVehicle: true },
    ]);
    state.adultOk = params.get('adult') === '0';
    openMenu({});
    if (params.get('request') === '1') {
      window.postMessage({
        action: 'request',
        request: { fromName: 'Maya R.', poseLabel: 'Standing', timeout: 20 },
      }, '*');
    }
  }
})();
