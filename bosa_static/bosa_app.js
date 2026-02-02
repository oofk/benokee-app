// BOSA Formulier Automatisering - Frontend JavaScript

// Tab functionaliteit
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    const tabName = btn.dataset.tab;
    
    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
      content.classList.remove('active');
    });
    document.getElementById(`tab-${tabName}`).classList.add('active');
  });
});

// Laad opgeslagen data
document.getElementById('load-saved-data')?.addEventListener('click', async () => {
  try {
    const response = await fetch('/api/load-data');
    const result = await response.json();
    
    if (result.success && result.data) {
      fillFormFromData(result.data);
      showMessage('Data geladen uit Excel', 'success');
    } else {
      showMessage('Geen opgeslagen data gevonden', 'info');
    }
  } catch (error) {
    showMessage(`Fout bij laden data: ${error.message}`, 'error');
  }
});

// Vul formulier met data
function fillFormFromData(data) {
  // Aanvrager
  if (data.aanvrager) {
    Object.keys(data.aanvrager).forEach(key => {
      const field = document.getElementById(key);
      if (field && data.aanvrager[key]) {
        field.value = data.aanvrager[key];
      }
    });
  }
  
  // Contact
  if (data.contact) {
    Object.keys(data.contact).forEach(key => {
      const field = document.getElementById(key);
      if (field && data.contact[key]) {
        field.value = data.contact[key];
      }
    });
  }
  
  // Bank
  if (data.bank) {
    Object.keys(data.bank).forEach(key => {
      const field = document.getElementById(key);
      if (field && data.bank[key]) {
        field.value = data.bank[key];
      }
    });
  }
  
  // Ondertekenaar
  if (data.ondertekenaar) {
    Object.keys(data.ondertekenaar).forEach(key => {
      const field = document.getElementById(key);
      if (field && data.ondertekenaar[key]) {
        field.value = data.ondertekenaar[key];
      }
    });
  }
}

// Sla data op
document.getElementById('save-data')?.addEventListener('click', async () => {
  try {
    const formData = collectFormData();
    
    const response = await fetch('/api/save-data', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData)
    });
    
    const result = await response.json();
    
    if (result.success) {
      showMessage('Data opgeslagen in Excel!', 'success');
    } else {
      showMessage(`Fout: ${result.message}`, 'error');
    }
  } catch (error) {
    showMessage(`Fout bij opslaan: ${error.message}`, 'error');
  }
});

// Verzamel formulier data
function collectFormData() {
  return {
    aanvrager: {
      naam_organisatie: document.getElementById('naam_organisatie')?.value || '',
      kvk_nummer: document.getElementById('kvk_nummer')?.value || '',
      btw_plichtig: document.getElementById('btw_plichtig')?.value || '',
      btw_aftrek: document.getElementById('btw_aftrek')?.value || '',
      straat: document.getElementById('straat')?.value || '',
      huisnummer: document.getElementById('huisnummer')?.value || '',
      postcode: document.getElementById('postcode')?.value || '',
      plaats: document.getElementById('plaats')?.value || '',
      provincie: document.getElementById('provincie')?.value || '',
      telefoon: document.getElementById('telefoon')?.value || '',
      email: document.getElementById('email')?.value || ''
    },
    contact: {
      voornaam_contact: document.getElementById('voornaam_contact')?.value || '',
      tussenvoegsel_contact: document.getElementById('tussenvoegsel_contact')?.value || '',
      achternaam_contact: document.getElementById('achternaam_contact')?.value || '',
      email_contact: document.getElementById('email_contact')?.value || '',
      telefoon_contact: document.getElementById('telefoon_contact')?.value || '',
      relatienummer: document.getElementById('relatienummer')?.value || ''
    },
    bank: {
      iban: document.getElementById('iban')?.value || '',
      banknaam: document.getElementById('banknaam')?.value || '',
      rekeninghouder: document.getElementById('rekeninghouder')?.value || ''
    },
    ondertekenaar: {
      tekenbevoegdheid: document.getElementById('tekenbevoegdheid')?.value || '',
      voornaam_ondertekenaar: document.getElementById('voornaam_ondertekenaar')?.value || '',
      tussenvoegsel_ondertekenaar: document.getElementById('tussenvoegsel_ondertekenaar')?.value || '',
      achternaam_ondertekenaar: document.getElementById('achternaam_ondertekenaar')?.value || '',
      functie_ondertekenaar: document.getElementById('functie_ondertekenaar')?.value || '',
      email_ondertekenaar: document.getElementById('email_ondertekenaar')?.value || '',
      telefoon_ondertekenaar: document.getElementById('telefoon_ondertekenaar')?.value || ''
    }
  };
}

// Download Excel
document.getElementById('download-excel')?.addEventListener('click', () => {
  window.location.href = '/api/download-excel';
});

// Upload kosten Excel
document.getElementById('upload-costs-excel')?.addEventListener('change', async (e) => {
  const file = e.target.files[0];
  if (!file) return;
  
  const formData = new FormData();
  formData.append('file', file);
  
  try {
    const response = await fetch('/api/upload-costs-excel', {
      method: 'POST',
      body: formData
    });
    
    const result = await response.json();
    
    if (result.success) {
      showMessage('Kosten Excel geladen!', 'success');
      loadCostsList();
    } else {
      showMessage(`Fout: ${result.message}`, 'error');
    }
  } catch (error) {
    showMessage(`Fout bij uploaden: ${error.message}`, 'error');
  }
});

// Download kosten Excel
document.getElementById('download-costs-excel')?.addEventListener('click', () => {
  window.location.href = '/api/download-costs-excel';
});

// Laad kosten lijst
async function loadCostsList() {
  try {
    const response = await fetch('/api/load-costs');
    const result = await response.json();
    
    if (result.success) {
      displayCostsList(result.costs);
    }
  } catch (error) {
    console.error('Fout bij laden kosten:', error);
  }
}

// Toon kosten lijst
function displayCostsList(costs) {
  const container = document.getElementById('costs-list');
  if (!costs || costs.length === 0) {
    container.innerHTML = '<p>Geen kosten gevonden. Upload een Excel bestand of voeg handmatig toe.</p>';
    return;
  }
  
  container.innerHTML = costs.map((cost, index) => `
    <div class="cost-item">
      <h4>Kosten ${index + 1}</h4>
      <pre>${JSON.stringify(cost, null, 2)}</pre>
    </div>
  `).join('');
}

// Start formulier invullen
document.getElementById('fill-form-btn')?.addEventListener('click', async () => {
  const statusBox = document.getElementById('fill-status');
  statusBox.classList.remove('hidden');
  statusBox.textContent = 'Formulier invullen wordt gestart...';
  statusBox.className = 'status-box info';
  
  try {
    const formData = collectFormData();
    const useSavedData = document.getElementById('use-saved-data')?.checked || false;
    const documentsDir = document.getElementById('documents-dir')?.value || null;
    
    // Laad kosten
    const costsResponse = await fetch('/api/load-costs');
    const costsResult = await costsResponse.json();
    const costsData = costsResult.success ? costsResult.costs : [];
    
    const response = await fetch('/api/fill-form', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        formData,
        costsData,
        documentsDir,
        useSavedData
      })
    });
    
    const result = await response.json();
    
    if (result.success) {
      statusBox.textContent = result.message;
      statusBox.className = 'status-box success';
    } else {
      statusBox.textContent = `Fout: ${result.message}`;
      statusBox.className = 'status-box error';
    }
  } catch (error) {
    statusBox.textContent = `Fout: ${error.message}`;
    statusBox.className = 'status-box error';
  }
});

// Analyseer formulier
document.getElementById('analyze-form')?.addEventListener('click', () => {
  showMessage('Formulier analyse wordt gestart. Zie console voor details.', 'info');
  // TODO: Implementeer formulier analyse
});

// Helper functie voor berichten
function showMessage(message, type = 'info') {
  // Eenvoudige alert voor nu, kan uitgebreid worden met een toast systeem
  const colors = {
    success: 'green',
    error: 'red',
    info: 'blue'
  };
  console.log(`[${type.toUpperCase()}] ${message}`);
  
  // Toon visueel bericht (kan uitgebreid worden)
  const msgDiv = document.createElement('div');
  msgDiv.style.cssText = `position: fixed; top: 20px; right: 20px; padding: 15px; background: ${colors[type] || 'gray'}; color: white; border-radius: 5px; z-index: 1000;`;
  msgDiv.textContent = message;
  document.body.appendChild(msgDiv);
  
  setTimeout(() => msgDiv.remove(), 5000);
}

// Laad kosten bij pagina load
loadCostsList();

