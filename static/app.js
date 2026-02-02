const state = {
  days: 5,
  persons: 4,
  dishes: [],
  standardItems: [],
  incidentalItems: [],
  selectedDishes: [],
  selectedStandard: new Set(),
  selectedIncidental: new Set(),
  bonusOffers: [],
  finalResult: null,
};

const stepButtons = document.querySelectorAll(".step-btn");
const stepContents = document.querySelectorAll(".step-content");

function showStep(step) {
  stepButtons.forEach((btn) => btn.classList.toggle("active", btn.dataset.step === String(step)));
  stepContents.forEach((content) => content.classList.toggle("hidden", content.id !== `step-${step}`));
}

function initNav() {
  document.getElementById("to-step-2").addEventListener("click", () => {
    state.days = Number(document.getElementById("days-input").value) || 5;
    state.persons = Number(document.getElementById("persons-input").value) || 4;
    buildDishSelectors();
    showStep(2);
  });

  document.querySelectorAll("[data-prev]").forEach((btn) => {
    btn.addEventListener("click", () => showStep(btn.dataset.prev));
  });
  document.querySelectorAll("[data-next]").forEach((btn) => {
    btn.addEventListener("click", () => showStep(btn.dataset.next));
  });

  stepButtons.forEach((btn) => {
    btn.addEventListener("click", () => showStep(btn.dataset.step));
  });
}

async function fetchJSON(url, options) {
  const res = await fetch(url, options);
  return res.json();
}

async function loadInitialData() {
  const [dishes, standard, incidental] = await Promise.all([
    fetchJSON("/api/dishes"),
    fetchJSON("/api/standard-items"),
    fetchJSON("/api/incidental-items"),
  ]);
  state.dishes = dishes;
  state.standardItems = standard;
  state.incidentalItems = incidental;

  // preset frequent standard items
  standard.filter((i) => i.isFrequent).forEach((i) => state.selectedStandard.add(i.id));
}

function buildDishSelectors() {
  const container = document.getElementById("dish-selectors");
  container.innerHTML = "";
  state.selectedDishes = Array.from({ length: state.days }, () => "");

  for (let i = 0; i < state.days; i++) {
    const wrapper = document.createElement("div");
    wrapper.className = "card";
    const label = document.createElement("label");
    label.textContent = `Dag ${i + 1}`;
    const select = document.createElement("select");
    const empty = document.createElement("option");
    empty.value = "";
    empty.textContent = "Geen gerecht";
    select.appendChild(empty);
    state.dishes.forEach((dish) => {
      const opt = document.createElement("option");
      opt.value = dish.id;
      opt.textContent = dish.name;
      select.appendChild(opt);
    });
    select.addEventListener("change", () => {
      state.selectedDishes[i] = select.value;
      renderIngredients();
    });
    wrapper.appendChild(label);
    wrapper.appendChild(select);
    container.appendChild(wrapper);
  }
}

function renderIngredients() {
  const selected = state.selectedDishes
    .map((id) => state.dishes.find((d) => d.id === id))
    .filter(Boolean);
  const ingredients = new Set();
  selected.forEach((dish) => {
    dish.ingredients.forEach((ing) => ingredients.add(ing));
  });
  const list = document.getElementById("ingredients-list");
  list.innerHTML = "";
  [...ingredients].forEach((ing) => {
    const li = document.createElement("li");
    li.textContent = ing;
    list.appendChild(li);
  });
}

function renderStandard() {
  const container = document.getElementById("standard-items");
  container.innerHTML = "";
  const grouped = groupBy(state.standardItems, "category");
  Object.entries(grouped).forEach(([cat, items]) => {
    const block = document.createElement("div");
    block.className = "category-block";
    const title = document.createElement("div");
    title.className = "category-title";
    title.textContent = cat;
    const toggle = document.createElement("button");
    toggle.textContent = "Alles aan/uit";
    toggle.className = "tiny";
    toggle.addEventListener("click", () => {
      const allSelected = items.every((i) => state.selectedStandard.has(i.id));
      items.forEach((i) => {
        if (allSelected) state.selectedStandard.delete(i.id);
        else state.selectedStandard.add(i.id);
      });
      renderStandard();
    });
    title.appendChild(toggle);
    block.appendChild(title);
    items.forEach((item) => {
      const row = document.createElement("label");
      row.className = "row";
      const cb = document.createElement("input");
      cb.type = "checkbox";
      cb.checked = state.selectedStandard.has(item.id);
      cb.addEventListener("change", () => {
        if (cb.checked) state.selectedStandard.add(item.id);
        else state.selectedStandard.delete(item.id);
      });
      row.appendChild(cb);
      const text = document.createElement("span");
      text.textContent = item.name + (item.forWhom ? ` (${item.forWhom})` : "");
      row.appendChild(text);
      if (item.note) {
        const note = document.createElement("small");
        note.textContent = item.note;
        row.appendChild(note);
      }
      block.appendChild(row);
    });
    container.appendChild(block);
  });
}

function renderIncidental() {
  const container = document.getElementById("incidental-items");
  container.innerHTML = "";
  const grouped = groupBy(state.incidentalItems, "category");
  Object.entries(grouped).forEach(([cat, items]) => {
    const block = document.createElement("div");
    block.className = "category-block";
    const title = document.createElement("div");
    title.className = "category-title";
    title.textContent = cat;
    block.appendChild(title);
    items.forEach((item) => {
      const row = document.createElement("label");
      row.className = "row";
      const cb = document.createElement("input");
      cb.type = "checkbox";
      cb.checked = state.selectedIncidental.has(item.id);
      cb.addEventListener("change", () => {
        if (cb.checked) state.selectedIncidental.add(item.id);
        else state.selectedIncidental.delete(item.id);
      });
      row.appendChild(cb);
      const text = document.createElement("span");
      text.textContent = item.name + (item.forWhom ? ` (${item.forWhom})` : "");
      row.appendChild(text);
      if (item.note) {
        const note = document.createElement("small");
        note.textContent = item.note;
        row.appendChild(note);
      }
      block.appendChild(row);
    });
    container.appendChild(block);
  });
}

function groupBy(list, key) {
  return list.reduce((acc, item) => {
    const k = item[key] || "Overig";
    acc[k] = acc[k] || [];
    acc[k].push(item);
    return acc;
  }, {});
}

async function fetchBonus() {
  const status = document.getElementById("bonus-status");
  status.textContent = "Bonus ophalen...";
  try {
    const offers = await fetchJSON("/api/bonus");
    state.bonusOffers = offers;
    status.textContent = `${offers.length} aanbiedingen gevonden.`;
    renderOffers(offers);
    await generateFinal(true);
  } catch (e) {
    status.textContent = "Kon bonus niet ophalen. Probeer later opnieuw.";
  }
}

function renderOffers(offers) {
  const container = document.getElementById("bonus-offers");
  container.innerHTML = "";
  offers.slice(0, 30).forEach((offer) => {
    const card = document.createElement("div");
    card.className = "offer";
    card.innerHTML = `<strong>${offer.name}</strong><br>${offer.price || ""}<br><small>${offer.description || ""}</small>`;
    container.appendChild(card);
  });
}

async function generateFinal(includeBonus) {
  const payload = {
    dishIds: state.selectedDishes.filter(Boolean),
    standardItemIds: Array.from(state.selectedStandard),
    incidentalItemIds: Array.from(state.selectedIncidental),
    includeBonusSuggestions: includeBonus,
  };
  const result = await fetchJSON("/api/generate-list", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  state.finalResult = result;
  renderFinal(result);
}

function renderFinal(result) {
  const container = document.getElementById("final-list");
  container.innerHTML = "";
  const grouped = result.grouped;
  Object.entries(grouped).forEach(([cat, items]) => {
    const block = document.createElement("div");
    block.className = "category-block";
    const title = document.createElement("div");
    title.className = "category-title";
    title.textContent = cat;
    block.appendChild(title);
    items.forEach((item) => {
      const row = document.createElement("div");
      row.className = "row final-row";
      const cb = document.createElement("input");
      cb.type = "checkbox";
      row.appendChild(cb);
      const text = document.createElement("span");
      text.textContent = item.name;
      row.appendChild(text);
      if (item.isOnBonus) {
        const tag = document.createElement("span");
        tag.className = "badge";
        tag.textContent = "Bonus";
        row.appendChild(tag);
      }
      block.appendChild(row);
    });
    container.appendChild(block);
  });

  const suggestions = document.getElementById("bonus-suggestions");
  suggestions.innerHTML = "";
  if (result.bonusSuggestions && result.bonusSuggestions.length) {
    const ul = document.createElement("ul");
    result.bonusSuggestions.forEach((s) => {
      const li = document.createElement("li");
      li.textContent = s;
      ul.appendChild(li);
    });
    suggestions.appendChild(document.createElement("h4")).textContent = "Bonus suggesties";
    suggestions.appendChild(ul);
  }

  const textArea = document.getElementById("export-text");
  textArea.value = buildExportText(grouped);
}

function buildExportText(grouped) {
  let lines = [];
  Object.entries(grouped).forEach(([cat, items]) => {
    lines.push(cat);
    items.forEach((item) => {
      const bonusLabel = item.isOnBonus ? " (BONUS)" : "";
      lines.push(`- ${item.name}${bonusLabel}`);
    });
    lines.push("");
  });
  return lines.join("\n");
}

function wireActions() {
  document.getElementById("fetch-bonus").addEventListener("click", fetchBonus);
  document.querySelector("[data-next='6']").addEventListener("click", () => generateFinal(false).then(() => showStep(6)));
  document.querySelector("[data-next='3']").addEventListener("click", () => renderStandard());
  document.querySelector("[data-next='4']").addEventListener("click", () => renderIncidental());
  document.getElementById("copy-btn").addEventListener("click", () => {
    const textArea = document.getElementById("export-text");
    textArea.select();
    textArea.setSelectionRange(0, textArea.value.length);
    document.execCommand("copy");
  });
}

async function init() {
  initNav();
  wireActions();
  await loadInitialData();
  buildDishSelectors();
}

init();

