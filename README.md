# Documento di Progettazione — Autochess Medievale a Carte (Godot)

**Titolo provvisorio:** *Reami di Guerra* (o *Corona d'Acciaio*, *Signori del Conflitto*)

---

## 1. Visione del Gioco

Un autochess tattico a base di carte, ambientato in un mondo medievale fantasy. Il giocatore interpreta un Signore che recluta unità, le schiera su un campo di battaglia e le vede combattere automaticamente contro un avversario. 

**La particolarità:** Le unità sono rappresentate da carte e ogni classe ha una specializzazione chiara e riconoscibile.

### Pilastri di Design
* 🛡️ **Chiarezza dei ruoli** → Ogni classe ha una funzione immediata.
* 👁️ **Sinergie leggibili** → Le combo si capiscono a colpo d'occhio.
* ⏱️ **Partite brevi** → 10-15 minuti per match.
* 🎲 **Progressione roguelike** → Ogni run sblocca qualcosa.
* ⚙️ **Data-driven** → Tutto definito tramite `Resource` in Godot.

---

## 2. Le Classi Base (Specializzazioni)

### 🛡️ Paladino — Il Muro Sacro
* **Ruolo:** Tank / Protettore
* **Meccanica chiave:** Genera Scudo (assorbe danno) e lo distribuisce ad alleati adiacenti.
* **Esempio abilità:** *"Baluardo Divino"* → $+15$ scudo a sé e $+8$ agli alleati adiacenti per 3 turni.
* **Statistiche base:** HP alto, Attacco basso, Difesa altissima.
* **Sinergia naturale:** Con Chierici (cura lo scudo), con Guerrieri (li protegge mentre attaccano).

### ✨ Chierico — La Mano della Luce
* **Ruolo:** Supporto / Guaritore
* **Meccanica chiave:** Cura alleati ogni turno; può resuscitare un'unità caduta una volta per partita.
* **Esempio abilità:** *"Preghiera Collettiva"* → Cura 10 HP a tutte le unità alleate.
* **Statistiche base:** HP medio, Attacco basso, Difesa bassa, Guarigione alta.
* **Sinergia naturale:** Con Paladini (mantiene gli scudi), con Mago (lo protegge).

### ⚔️ Guerriero — La Lama Ruggente
* **Ruolo:** DPS puro / Damage dealer
* **Meccanica chiave:** Danno fisico elevato, effetto sanguinamento (danno nel tempo).
* **Esempio abilità:** *"Furia Barbarica"* → $+30\%$ attacco per 2 turni, ma $-10\%$ difesa.
* **Statistiche base:** HP medio-alto, Attacco altissimo, Difesa media.
* **Sinergia naturale:** Con Paladini (li tanka), con Chierici (lo cura dopo la furia).

### 🔥 Mago — Il Fuoco Arcano
* **Ruolo:** DPS magico / Area damage
* **Meccanica chiave:** Brucia i nemici (danno nel tempo), colpisce più bersagli.
* **Esempio abilità:** *"Palla di Fuoco"* → 20 danno a un bersaglio $+ 5$ bruciatura per 3 turni.
* **Statistiche base:** HP basso, Attacco magico altissimo, Difesa bassissima.
* **Sinergia naturale:** Con Paladini (lo proteggono), con Chierici (lo curano).

### 🏹 (Bonus) Arciere — L'Occhio Lontano
* **Ruolo:** DPS a distanza
* **Meccanica chiave:** Colpisce le unità più deboli in fondo.
* **Esempio abilità:** *"Tiro Perforante"* → Ignora lo scudo.
* **Statistiche base:** HP basso, Attacco alto, Difesa bassa.

---

## 3. Sistema di Scudi, Cura, Danno

### Tabella Effetti e Statuti

| Tipo | Effetto | Stack? | Durata |
| :--- | :--- | :---: | :--- |
| **Scudo** | Assorbe danno prima degli HP | Sì, si somma | Finché non si rompe o scade |
| **Cura** | Ripristina HP | No, si applica subito | Istantanea |
| **Bruciatura** | Danno magico nel tempo | Sì (si somma) | 3 turni tipicamente |
| **Sanguinamento** | Danno fisico nel tempo | Sì (si somma) | 3 turni tipicamente |
| **Resurrezione** | Riporta in vita con $50\%$ HP | Una volta per unità | Istantanea |

### Ordine di Risoluzione del Danno
1. Lo **Scudo** assorbe il danno.
2. Si applicano eventuali **riduzioni percentuale (%)**.
3. Il danno residuo intacca gli **HP**.
4. Se $\text{HP} \le 0$ $\rightarrow$ l'unità cade.

---

## 4. Sistemi di Gioco

### 4.1 Reclutamento (Shop)
* 5 slot di unità casuali per turno.
* Ogni unità ha un costo (1-5 monete d'oro).
* Le unità più costose sono più rare.
* È possibile bloccare lo shop per il turno successivo.

### 4.2 Fusione / Potenziamento
* **3 unità identiche** $\rightarrow$ si fondono in una versione élite (Livello 2).
* **3 unità élite** $\rightarrow$ Livello 3 (massimo).
* Ogni livello aumenta le statistiche e potenzia l'abilità.

### 4.3 Posizionamento
* Griglia $6 \times 4$ (24 caselle totali, 12 per lato).
* **Posizioni frontali:** Esposte ai danni.
* **Posizioni retro:** Protette.
* Le sinergie dipendono dalla distanza tra le unità.

### 4.4 Sinergie / Fazioni
Ogni unità appartiene a **1 Classe + 1 Fazione**. Le combinazioni creano profondità strategica.

* **Ordine della Corona:** 2/4/6 unità = $+5\% / +10\% / +20\%$ scudo.
* **Conclave Arcano:** 2/4/6 unità = $+10\% / +20\% / +35\%$ danno magico.
* **Orda del Nord:** 2/4/6 unità = $+10\% / +20\% / +35\%$ attacco fisico.

### 4.5 Combattimento Automatico
* Turni simultanei.
* **Ordine di azione:** Paladini $\rightarrow$ Guerrieri $\rightarrow$ Arcieri $\rightarrow$ Maghi $\rightarrow$ Chierici.
* Ogni unità agisce secondo la sua priorità (definita nell'abilità).
* Durata massima: 30 turni. Scaduto il tempo, vince chi ha più HP totali.

### 4.6 Risorse
* **Oro:** Utilizzato per acquistare unità.
* **Onore:** Risorsa speciale per abilità del Signore.
* **Livello Signore:** Aumenta gli slot sul campo e la qualità delle unità nello shop.

---

## 5. Il Signore (Eroe Giocatore)

Il giocatore non combatte direttamente, ma possiede abilità passive/attive scelte a inizio partita:

* **Il Re Guerriero:** $+10\%$ attacco a tutti i Guerrieri.
* **La Regina Sacerdotessa:** Le cure sono $+25\%$ più efficaci.
* **Il Signore Oscuro:** I nemici subiscono $+1$ danno da bruciatura.

---

## 6. Struttura Tecnica in Godot 4

### 6.1 Struttura Cartelle

```text
res://
├── assets/
│   ├── carte/          # Immagini delle carte
│   ├── icone/          # Icone abilità
│   └── audio/
├── data/
│   ├── unita/          # .tres (Resource) di ogni unità
│   ├── fazioni/        # .tres delle fazioni
│   └── signori/        # .tres dei Signori
├── scenes/
│   ├── main.tscn
│   ├── battaglia.tscn
│   ├── shop.tscn
│   └── unita/
│       └── unita.tscn
├── scripts/
│   ├── sistema/
│   │   ├── combattimento.gd
│   │   ├── shop.gd
│   │   └── sinergie.gd
│   ├── unita/
│   │   └── unita.gd
│   └── ui/
│       └── carta_ui.gd
└── resources/
    └── unita.gd        # class_name Unita
```

### 6.2 Script Unita (Resource)

```gdscript
class_name Unita extends Resource

@export var id: String
@export var nome: String
@export var descrizione: String
@export var icona: Texture2D
@export var classe: String         # Paladino, Chierico, Guerriero, Mago, Arciere
@export var fazione: String        # Corona, Conclave, Orda, ...
@export var costo: int             # 1-5
@export var hp_max: int
@export var attacco: int
@export var difesa: int
@export var velocita: int
@export var abilita: Abilita
@export var scudo_base: int = 0
@export var cura_base: int = 0
@export var bruciatura_base: int = 0
@export var sanguinamento_base: int = 0
```

### 6.3 Script Abilita (Resource)

```gdscript
class_name Abilita extends Resource

@export var nome: String
@export var descrizione: String
@export var tipo: String           # danno, cura, scudo, debuff, buff
@export var valore: int
@export var durata: int
@export var bersagli: String       # singolo, area, tutti_alleati, tutti_nemici
@export var cooldown: int
```

### 6.4 Loop di Combattimento (Pseudo-codice)

```gdscript
func risolvi_turno():
    var ordine = ordina_per_priorita(alleati + nemici)
    for unita in ordine:
        if unita.hp <= 0: continue
        applica_effetti_passivi(unita)
        esegui_abilita(unita)
        applica_bruciature_e_sanguinamenti()
        verifica_morti()
        verifica_vittoria()
```

---

## 7. Roadmap di Sviluppo

- [ ] **Fase 1 — Prototipo (2-4 settimane)**
  - Griglia $6 \times 4$ funzionante
  - 6 unità placeholder (2 Paladini, 2 Guerrieri, 1 Chierico, 1 Mago)
  - Combattimento automatico base
  - Log di battaglia testuale
- [ ] **Fase 2 — Core Loop (4-6 settimane)**
  - Shop con 5 slot
  - Fusione 3$\rightarrow$1
  - Sinergie base (2 fazioni)
  - Round vs IA
  - UI carte placeholder
- [ ] **Fase 3 — Contenuti (6-8 settimane)**
  - 20+ unità
  - 4+ fazioni
  - 3 Signori giocabili
  - Abilità complete (scudo, cura, brucia, sanguina)
  - Effetti visivi base (Tween, particelle)
- [ ] **Fase 4 — Polish (4 settimane)**
  - Bilanciamento
  - Audio
  - Salvataggi
  - Menu, tutorial
  - Build export
- [ ] **Fase 5 — Espansione (Post-lancio)**
  - PvP asincrono
  - Modalità roguelike
  - Nuove classi (Arciere, Ladro, Druido...)
  - Eventi settimanali

---

## 8. Idee Extra

* **8.1 Sistema di "Fedeltà":** Valore $0-100$ per unità. Cresce combattendo e sblocca abilità speciali ad alta fedeltà. Sacrificare l'unità in una fusione riduce la fedeltà.
* **8.2 Reliquie di Guerra:** Passivi permanenti post-vittoria (*Stendardo del Corvo* $+10\%$ attacco; *Calice Sacro* $+20\%$ cure; *Anello di Fuoco* $+1$ turno bruciatura).
* **8.3 Eventi tra Round:** Scelte fra 2-3 opzioni (es. acquistare reliquie, reclutare prigionieri, sacrificare unità per oro).
* **8.4 Modalità Assedio:** PvE a ondate dove occorre espugnare un castello con posizioni nemiche fisse.
* **8.5 Sinergie Dinamiche:** Bonus che variano in base al contesto (es. ciclo giorno/notte o "guerre sante").

---

## 9. Errori da Evitare

* ❌ **Troppe classi subito:** Iniziare con 4-5 e espandere in seguito.
* ❌ **Sinergie complesse:** Devono essere comprensibili in pochissimi secondi.
* ❌ **RNG sbilanciato:** Utilizzare fogli di calcolo per la calibrazione matematica.
* ❌ **Copiare direttamente altri titoli:** Ispirarsi senza clonare.
* ❌ **Grafica prima del gameplay:** Usare placeholder finché il loop non è solido.
* ❌ **Feature creep:** Completare ogni meccanica prima di aprirne di nuove.

---

## 10. Prossimi Passi Concreti

1. Decidere l'ambientazione dettagliata (solo umani, mostri, magia, non-morti).
2. Definire le prime 6 unità (2 per classe principale).
3. Creare il primo prototipo della griglia su Godot.
4. Implementare il sistema di combattimento testuale.
5. Verificare la giocabilità e il divertimento del core loop.
