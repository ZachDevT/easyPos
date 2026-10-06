# Build a Professional Offline Flutter POS System for Congolese Retail Businesses

## 1. PROJECT OVERVIEW

Build a **modern, beautiful, cute, professional and extremely user-friendly Point of Sale (POS) desktop application** using **Flutter/Dart**, primarily targeting **Windows desktop**.

The application is designed for small and medium-sized businesses in the **Democratic Republic of Congo (DRC)**, including:

* Boutiques
* Supermarkets
* Mini-markets
* Pharmacies
* Cosmetics shops
* Clothing stores
* Electronics shops
* Hardware stores
* General retail businesses

The application must be **offline-first**.

The user should be able to run the entire business without an Internet connection.

Internet must NOT be required for:

* Creating products
* Selling products
* Managing stock
* Printing receipts
* Creating invoices
* Managing customers
* Recording expenses
* Viewing reports
* Importing products
* Exporting data
* Barcode scanning

The application should feel like a **small professional business management system**, not a complicated accounting application.

The philosophy is:

> **Simple enough for a cashier to learn in 10 minutes, but powerful enough for a serious small business.**

---

# 2. TECHNOLOGY

Use:

* Flutter
* Dart
* Flutter Windows Desktop
* Clean Architecture
* Feature-based project structure
* Local SQLite database
* Repository pattern
* Riverpod or another robust state-management solution
* Responsive desktop UI
* Local file storage for product images
* PDF generation
* Excel/CSV import/export
* Barcode support
* Thermal printer support

Recommended database:

**SQLite**

Possible packages can include:

* drift
* flutter_riverpod
* go_router
* pdf
* printing
* excel
* csv
* file_picker
* image_picker
* path_provider
* barcode
* intl
* shared_preferences

Choose stable packages compatible with Windows.

Do NOT introduce unnecessary cloud services.

---

# 3. OFFLINE-FIRST REQUIREMENT

This is one of the most important requirements.

The application must work completely offline.

All core business data must be stored locally.

The application should continue working if:

```text
Internet = OFF
Wi-Fi = OFF
Mobile data = OFF
```

The user should still be able to:

* Open POS
* Sell products
* Scan barcodes
* Add products
* Edit products
* Update stock
* Create invoices
* Print receipts
* Manage customers
* View reports
* Import CSV/Excel
* Export reports
* Backup database

Show a small status indicator:

```text
● Offline
```

Do not make the user feel that offline mode is an error.

Instead, make offline operation a normal state.

---

# 4. TARGET CURRENCY AND LOCALIZATION

The default currency should be:

**CDF — Congolese Franc**

Allow the business administrator to change the currency if needed.

Support:

* CDF
* USD
* EUR
* Custom currency

Examples:

```text
25,000 CDF
15,500 CDF
$20
€15
```

Do not hard-code dollar currency throughout the application.

Use configurable currency settings.

Default language:

**French**

The interface should be written in simple, natural French suitable for Congolese businesses.

Structure the application so additional languages can later be added:

* French
* English
* Swahili

---

# 5. DESIGN PHILOSOPHY

The UI must be:

### Cute + Professional + Modern

Do NOT make it look like an old accounting application.

Avoid:

* Gray boring tables everywhere
* Tiny buttons
* Too many menus
* Complicated forms
* Excessive technical terminology
* Cluttered dashboards

Use:

* Rounded cards
* Soft shadows
* Clear spacing
* Friendly icons
* Large buttons
* Beautiful typography
* Clear hierarchy
* Product images
* Friendly empty states
* Smooth animations
* Light and dark themes

The application should feel similar to a modern SaaS application while remaining practical for a physical store.

Think:

> **Modern retail + Apple-like simplicity + friendly African business software.**

Use a professional but warm color system.

Suggested palette:

```text
Primary:      #2563EB
Success:      #16A34A
Warning:      #F59E0B
Danger:       #DC2626
Background:   #F8FAFC
Cards:        #FFFFFF
Text:         #0F172A
Muted text:   #64748B
```

Allow the business owner to later customize the primary color.

---

# 6. MAIN APPLICATION STRUCTURE

Create a left sidebar navigation.

Example:

```text
┌───────────────────────────────┐
│        BUSINESS LOGO          │
│        Business Name          │
├───────────────────────────────┤
│ 🏠 Tableau de bord            │
│ 🛒 Caisse                     │
│ 📦 Produits                   │
│ 🏷️ Catégories                 │
│ 📊 Stock                      │
│ 👥 Clients                    │
│ 🧾 Ventes                     │
│ 📄 Factures                   │
│ 📈 Rapports                   │
│ 💸 Dépenses                   │
│ 👤 Utilisateurs               │
│ ⚙️ Paramètres                 │
├───────────────────────────────┤
│ ● Hors ligne                  │
└───────────────────────────────┘
```

Use icons and labels.

Allow the sidebar to collapse.

---

# 7. DASHBOARD

Create a beautiful business dashboard.

At the top:

```text
Bonjour 👋

Voici ce qui se passe dans votre entreprise aujourd'hui.
```

Show cards:

```text
Ventes aujourd'hui
250,000 CDF

Transactions
37

Bénéfice estimé
85,000 CDF

Produits en stock
1,284
```

Then:

### Sales chart

Display:

* Today's sales
* Weekly sales
* Monthly sales

### Popular products

Show:

```text
1. Coca-Cola 50cl
2. Savon
3. Paracétamol
4. T-shirt homme
5. Sucre 1kg
```

### Low-stock alert

Example:

```text
⚠️ Stock faible

Paracétamol       4 unités
Savon Lux         6 unités
T-shirt XL        2 unités

[Voir le stock]
```

### Recent sales

Display the latest transactions.

---

# 8. POS / CASH REGISTER

This is the most important screen.

Design it for speed.

Layout:

```text
┌───────────────────────────────────────────────────────────┐
│ 🔎 Rechercher produit ou scanner un code-barres            │
├───────────────────────────────┬───────────────────────────┤
│                               │                           │
│   PRODUCT GRID                │       PANIER              │
│                               │                           │
│  [Image] Coca-Cola            │ Coca-Cola      2          │
│  2,000 CDF                    │ 4,000 CDF                 │
│                               │                           │
│  [Image] Savon                │ Savon          1          │
│  3,500 CDF                    │ 3,500 CDF                 │
│                               │                           │
│  [Image] T-shirt              │                           │
│  25,000 CDF                   │ Sous-total: 7,500 CDF     │
│                               │ Réduction: 0 CDF          │
│                               │ TOTAL: 7,500 CDF          │
│                               │                           │
│                               │ [ENCAISSER]               │
└───────────────────────────────┴───────────────────────────┘
```

Features:

* Product search
* Product categories
* Product images
* Barcode scanning
* Keyboard shortcuts
* Quantity adjustment
* Remove product
* Discount
* Customer selection
* Hold cart
* Resume cart
* Clear cart
* Payment
* Print receipt
* Save sale

---

# 9. BARCODE SUPPORT

Support common retail barcodes.

Examples:

* EAN-13
* EAN-8
* UPC
* Code 128

Allow barcode input through:

1. USB barcode scanner
2. Keyboard scanner
3. Manual barcode entry

Most USB barcode scanners behave like keyboards, so make the POS compatible with this workflow.

When a barcode is scanned:

```text
Scan
↓
Find product
↓
Add product to cart
↓
Increase quantity if already present
```

If product does not exist:

```text
Produit introuvable

[Créer ce produit]
```

---

# 10. PRODUCT MANAGEMENT

Create a beautiful product management page.

Display products as cards or table.

Each product should support:

```text
Product ID
Name
SKU
Barcode
Category
Brand
Description
Product image
Purchase price
Selling price
Wholesale price
Stock quantity
Minimum stock
Unit
Supplier
Expiration date
Batch number
Active/Inactive
```

Examples of units:

* pièce
* boîte
* paquet
* kg
* g
* litre
* ml
* bouteille
* carton

---

# 11. PRODUCT CREATION

Create a very friendly product creation form.

Sections:

### Basic information

```text
Nom du produit
Catégorie
Marque
Description
Image
```

### Identification

```text
SKU
Code-barres
```

### Pricing

```text
Prix d'achat
Prix de vente
Prix grossiste
```

### Inventory

```text
Stock initial
Stock minimum
Unité
```

### Optional pharmacy fields

If business type = Pharmacy:

```text
Lot
Date d'expiration
Dosage
Forme
Fabricant
```

Do not force pharmacy fields on normal boutiques.

Use conditional fields.

---

# 12. PRODUCT IMAGES

Allow the user to:

* Upload image from computer
* Take image where supported
* Change image
* Remove image

Automatically resize/compress images to avoid huge local storage.

Display images as beautiful product thumbnails.

---

# 13. IMPORT PRODUCTS FROM EXCEL / CSV

This is extremely important.

Allow:

```text
Importer des produits
```

Supported:

* CSV
* XLSX

Provide a template:

```text
nom
sku
barcode
categorie
prix_achat
prix_vente
stock
stock_minimum
unite
marque
```

Example:

```csv
nom,sku,barcode,categorie,prix_achat,prix_vente,stock,stock_minimum,unite
Coca Cola,COKE001,5449000000996,Boissons,1500,2000,100,20,pièce
Savon,SAV001,123456789,Hygiène,2500,3500,50,10,pièce
```

Import process:

```text
Select file
↓
Read file
↓
Preview rows
↓
Validate
↓
Show errors
↓
Confirm import
↓
Import
↓
Show summary
```

Example:

```text
Importation terminée

✓ 245 produits importés
✓ 12 produits mis à jour
⚠️ 3 lignes avec erreurs
```

Allow exporting errors.

---

# 14. STOCK MANAGEMENT

Create a dedicated stock page.

Show:

```text
Total products
Total stock units
Low stock
Out of stock
Stock value
```

Features:

* Stock adjustment
* Stock entry
* Stock exit
* Stock transfer (future-ready)
* Stock history
* Inventory valuation
* Low-stock alerts
* Out-of-stock alerts

Stock movement types:

```text
Achat
Vente
Retour client
Ajustement
Perte
Produit expiré
Correction
```

Never silently modify stock.

Every stock change should create a stock movement record.

---

# 15. LOW STOCK ALERTS

Allow each product to have:

```text
Stock minimum = 10
```

When:

```text
current stock <= minimum stock
```

show:

```text
⚠️ Stock faible
```

Dashboard notification:

```text
12 produits nécessitent votre attention
```

Allow sorting:

```text
Critique
Faible
Normal
```

---

# 16. SALES

Create a sales history page.

Columns:

```text
N° vente
Date
Client
Caissier
Articles
Total
Paiement
Statut
```

Allow:

* View sale
* Print receipt
* Generate invoice
* Refund
* Cancel sale
* View customer
* Export

---

# 17. PAYMENT METHODS

Support local payment methods.

Default:

```text
💵 Espèces
📱 Mobile Money
🏦 Banque
💳 Carte
📝 Crédit
```

Allow the administrator to create custom payment methods.

Examples:

```text
M-Pesa
Airtel Money
Orange Money
Cash
Bank
```

Do NOT require API integrations.

For basic operation, these are simply recorded payment methods.

---

# 18. CREDIT / CUSTOMER DEBT

Because many local businesses sell on credit, support:

```text
Vente à crédit
```

Customer account:

```text
Client: Jean

Total achats:       450,000 CDF
Total payé:         300,000 CDF
Reste à payer:      150,000 CDF
```

Allow:

* Record payment
* View debt history
* Print statement
* Customer balance

---

# 19. CUSTOMERS

Customer management.

Fields:

```text
Nom complet
Téléphone
Email
Adresse
Notes
Credit limit
Balance
```

Customer profile:

```text
Informations
Achats
Factures
Paiements
Dette
```

---

# 20. RECEIPTS

Generate professional receipts.

Support:

### Thermal receipt

Default:

```text
58mm
80mm
```

Receipt:

```text
--------------------------------
        BUSINESS NAME
        Votre slogan
        Goma, RDC
        Téléphone: +243 XXX XXX XXX
--------------------------------

Ticket: #000125
Date: 06/10/2026
Caissier: Admin

Coca Cola       2 x 2,000
                 4,000 CDF

Savon           1 x 3,500
                 3,500 CDF

--------------------------------
Sous-total:      7,500 CDF
Réduction:           0 CDF
TOTAL:           7,500 CDF

Paiement: ESPÈCES

Merci pour votre achat ❤️
--------------------------------
```

Allow business customization:

* Logo
* Name
* Address
* Phone
* WhatsApp
* Footer
* Thank-you message

---

# 21. THERMAL PRINTER SUPPORT

Support common Windows thermal printers.

Target:

```text
58mm
80mm
```

Implement printing through Windows printer support.

Allow:

```text
Paramètres
→ Imprimante
→ Sélectionner imprimante
→ Tester impression
```

Provide:

```text
Imprimer un ticket test
```

Also support normal A4 printers.

---

# 22. INVOICES

Allow generation of professional A4 invoices.

Invoice should contain:

```text
Business logo
Business name
Address
Phone
Email
Invoice number
Date
Customer
Items
Quantity
Unit price
Discount
Subtotal
Tax
Total
Payment status
Notes
```

Generate:

**PDF**

Allow:

```text
Voir PDF
Enregistrer
Imprimer
```

Invoice numbers:

```text
FAC-2026-000001
FAC-2026-000002
```

Make numbering configurable.

---

# 23. REPORTS

Create a beautiful Reports section.

Reports:

### Sales

* Daily sales
* Weekly sales
* Monthly sales
* Annual sales
* Sales by cashier
* Sales by category
* Sales by product

### Inventory

* Current stock
* Low stock
* Out of stock
* Stock value
* Stock movements

### Financial

* Revenue
* Cost of goods
* Gross profit
* Expenses
* Net estimated profit

### Customers

* Top customers
* Customer purchases
* Customer debts

Allow:

```text
Date range
Export PDF
Export Excel
Export CSV
Print
```

---

# 24. EXPENSES

Create simple expense management.

Examples:

```text
Transport
Electricity
Rent
Internet
Salary
Maintenance
Other
```

Fields:

```text
Description
Category
Amount
Date
Payment method
Notes
```

Show expenses in reports.

---

# 25. USERS AND ROLES

Support:

### Admin

Full access.

### Manager

Sales + inventory + reports.

### Cashier

POS + sales + customers.

### Stock Manager

Products + inventory.

Use PIN/password login.

Keep permissions simple.

---

# 26. BUSINESS SETUP

First launch should display a setup wizard.

### Step 1

```text
Bienvenue 👋
Configurons votre entreprise.
```

### Step 2

Business type:

```text
Boutique
Supermarché
Pharmacie
Restaurant
Cosmétiques
Électronique
Autre
```

### Step 3

Business information:

```text
Nom
Logo
Téléphone
Adresse
Ville
Province
Pays
```

Default:

```text
République Démocratique du Congo
```

### Step 4

Currency:

```text
CDF
USD
EUR
```

### Step 5

Printer setup.

### Step 6

Create administrator.

Then:

```text
Votre caisse est prête 🎉
```

---

# 27. BACKUP AND RESTORE

This is critical for an offline application.

Create:

```text
Paramètres
→ Sauvegarde
```

Actions:

```text
Créer une sauvegarde
Restaurer une sauvegarde
Exporter les données
```

Backup should include:

* SQLite database
* Product images
* Settings

Use a portable backup format.

Example:

```text
backup_2026-10-06.posbackup
```

Allow users to save backups to:

* USB drive
* Desktop
* Documents
* External drive

Show:

```text
Dernière sauvegarde:
Aujourd'hui à 09:20
```

Add optional automatic local backups.

---

# 28. DATA SAFETY

Never delete important records immediately.

For important entities use:

```text
soft delete
```

For sales and financial records:

Do NOT allow destructive deletion.

Use:

```text
Annuler
Rembourser
Corriger
```

Keep an audit trail.

---

# 29. SEARCH

Global search should be fast.

Search products by:

* Name
* SKU
* Barcode
* Category
* Brand

Search customers by:

* Name
* Phone

Search invoices by:

* Invoice number
* Customer

---

# 30. KEYBOARD SHORTCUTS

Because this is a desktop POS, optimize for keyboard.

Examples:

```text
F1 = POS
F2 = Search product
F4 = Payment
F5 = Hold cart
F6 = Customer
F8 = Discount
F9 = Print
ESC = Close dialog
Ctrl + N = New sale
Ctrl + P = Print
```

Display shortcuts subtly in tooltips.

---

# 31. RESPONSIVENESS

The application is primarily Windows desktop.

Support:

```text
1366x768
1440x900
1920x1080
```

Do not allow UI elements to overlap.

Support smaller laptop screens gracefully.

Use responsive layouts.

---

# 32. DARK MODE

Support:

```text
☀️ Light
🌙 Dark
🖥️ System
```

Make both themes beautiful.

---

# 33. EMPTY STATES

Do not show ugly blank screens.

Example:

```text
📦

Aucun produit pour le moment.

Ajoutez votre premier produit
pour commencer à vendre.

[+ Ajouter un produit]
```

Use friendly illustrations/icons.

---

# 34. ERROR HANDLING

Errors should be understandable.

Never show:

```text
SQLiteException...
NullPointerException...
```

to normal users.

Instead:

```text
Impossible d'enregistrer le produit.

Veuillez vérifier les informations
et réessayer.
```

Provide technical logging separately.

---

# 35. PERFORMANCE

The POS must feel instant.

Target:

* Product search <100ms for normal datasets
* Barcode lookup extremely fast
* POS cart updates instantly
* Database operations asynchronous
* No blocking UI
* Efficient image loading
* Pagination for large tables

The system should be capable of handling at least:

```text
50,000+ products
100,000+ sales
```

without becoming unusably slow.

---

# 36. DATABASE DESIGN

Create proper relational tables.

At minimum:

```text
business
users
roles
permissions

products
categories
brands
units

customers
suppliers

sales
sale_items
payments

invoices
invoice_items

stock_movements

expenses

settings

audit_logs
```

Use foreign keys and indexes.

Important indexes:

```text
products.barcode
products.sku
products.name
sales.created_at
customers.phone
invoices.invoice_number
```

---

# 37. ARCHITECTURE

Use a clean feature-oriented architecture.

Example:

```text
lib/
 ├── core/
 │   ├── database/
 │   ├── theme/
 │   ├── routing/
 │   ├── utils/
 │   ├── widgets/
 │   └── constants/
 │
 ├── features/
 │   ├── auth/
 │   ├── dashboard/
 │   ├── pos/
 │   ├── products/
 │   ├── categories/
 │   ├── inventory/
 │   ├── customers/
 │   ├── sales/
 │   ├── invoices/
 │   ├── expenses/
 │   ├── reports/
 │   ├── printers/
 │   ├── backup/
 │   └── settings/
 │
 └── main.dart
```

Keep business logic out of widgets.

Use repositories and services.

---

# 38. REUSABLE UI COMPONENTS

Create reusable components:

```text
AppSidebar
AppTopBar
StatCard
ProductCard
ProductImage
SearchBar
DataTable
StatusBadge
PrimaryButton
SecondaryButton
ConfirmDialog
MoneyText
EmptyState
LoadingState
ErrorState
DateRangePicker
PaymentDialog
QuantitySelector
```

Do not duplicate UI code.

---

# 39. SECURITY

Since this is offline:

* Hash passwords/PINs
* Protect admin settings
* Restrict sensitive operations
* Require admin PIN for refunds/settings if configured
* Keep audit logs
* Do not store passwords in plain text

---

# 40. PHARMACY MODE

The system must not become unnecessarily complicated for normal stores.

However, if the business chooses:

```text
Pharmacie
```

enable additional fields:

```text
Drug name
Generic name
Dosage
Form
Batch
Expiration date
Manufacturer
Prescription required
```

Add expiration alerts:

```text
🔴 Expired
🟠 Expires soon
🟢 Valid
```

Allow FEFO-style stock management later:

**First Expire, First Out.**

This should be modular, not forced on boutiques.

---

# 41. BUSINESS CUSTOMIZATION

Settings should allow:

```text
Business name
Logo
Address
Phone
WhatsApp
Email
Tax number
Currency
Receipt footer
Invoice footer
Primary color
Theme
Language
Printer
```

The application should adapt its branding based on these settings.

---

# 42. TAX SUPPORT

Do not assume one tax structure.

Allow:

```text
Tax enabled: Yes/No
Tax name
Tax percentage
Prices include tax: Yes/No
```

For example:

```text
TVA: 16%
```

But do not hard-code the tax rate.

---

# 43. DEMO DATA

Include a demo-data generator.

The developer should be able to run:

```text
Generate Demo Data
```

Create realistic products such as:

### Boutique

```text
T-shirt
Jean
Chaussures
Robe
Chemise
Sac
```

### Supermarket

```text
Coca-Cola
Fanta
Sucre
Riz
Huile
Savon
Lait
```

### Pharmacy

```text
Paracétamol
Amoxicilline
Ibuprofène
Vitamine C
```

The user should be able to select business type and generate relevant demo products.

---

# 44. IMPORTANT UX RULES

The application must follow these rules:

### Rule 1

A cashier should be able to make a sale with minimal clicks.

### Rule 2

Do not force users to fill unnecessary information.

### Rule 3

Use defaults wherever possible.

### Rule 4

Use friendly language.

### Rule 5

Make important actions visually obvious.

### Rule 6

Never hide the total amount.

### Rule 7

Always show stock availability.

### Rule 8

Use confirmation dialogs only for dangerous actions.

### Rule 9

Avoid complicated configuration.

### Rule 10

Everything should feel fast.

---

# 45. VISUAL DETAILS

Make the application feel polished.

Use:

* Rounded corners
* Consistent spacing
* Soft shadows
* Beautiful icons
* Product thumbnails
* Status chips
* Smooth transitions
* Hover states
* Tooltips
* Keyboard focus states
* Loading indicators
* Skeleton loading where appropriate

Buttons should have clear labels:

```text
+ Ajouter
Enregistrer
Annuler
Modifier
Supprimer
Imprimer
Exporter
Importer
Encaisser
```

Avoid ambiguous icons without labels for important operations.

---

# 46. ONBOARDING

When launching for the first time:

```text
Bienvenue dans votre caisse 👋

Gérez vos produits, vos ventes
et votre stock simplement.

[Commencer]
```

Then guide the user through setup.

Keep onboarding under 2–3 minutes.

---

# 47. INSTALLER / DEPLOYMENT

Create a production-ready Windows build.

The final project should support:

```bash
flutter build windows --release
```

Provide instructions for creating an installer.

The final application should install like normal Windows software:

```text
Setup.exe
```

It should create:

```text
Desktop shortcut
Start Menu shortcut
Application data directory
```

Do not require the end user to install Flutter, Dart, Git or VS Code.

---

# 48. DATABASE LOCATION

Store application data in an appropriate Windows application-data directory rather than inside the installation folder.

Example conceptual structure:

```text
AppData/
 └── CongolesePOS/
      ├── database/
      ├── images/
      ├── backups/
      ├── exports/
      └── logs/
```

The exact Windows path should follow Flutter/Windows conventions.

---

# 49. DEVELOPMENT PHASES

Do not attempt to build everything randomly.

Build in phases.

### Phase 1 — Foundation

* Flutter Windows
* Architecture
* Theme
* Database
* Navigation
* Settings
* Business setup

### Phase 2 — Products

* Categories
* Products
* Images
* Barcode
* Import CSV
* Import Excel

### Phase 3 — POS

* Cart
* Product search
* Barcode
* Payments
* Sales
* Receipts

### Phase 4 — Inventory

* Stock
* Stock movements
* Low-stock alerts
* Inventory valuation

### Phase 5 — Customers

* Customer management
* Credit
* Payments
* Statements

### Phase 6 — Invoices

* PDF invoices
* Printing
* Invoice numbering

### Phase 7 — Reports

* Sales
* Products
* Stock
* Profit
* Expenses
* Customers

### Phase 8 — Hardware

* Barcode scanners
* Thermal printers
* A4 printers

### Phase 9 — Backup

* Backup
* Restore
* Export/import

### Phase 10 — Polish

* Animations
* Dark mode
* Empty states
* Error handling
* Performance optimization
* Windows installer

---

# 50. ACCEPTANCE TEST

Before considering the application complete, test this complete scenario:

1. Install application on a fresh Windows computer.
2. Start application without Internet.
3. Create a business.
4. Select "Boutique".
5. Set currency to CDF.
6. Add categories.
7. Create 20 products.
8. Add product images.
9. Assign barcodes.
10. Import 100 products from Excel.
11. Check imported products.
12. Add stock.
13. Scan a product barcode.
14. Add products to cart.
15. Change quantity.
16. Apply discount.
17. Add customer.
18. Select cash payment.
19. Complete sale.
20. Automatically reduce stock.
21. Print thermal receipt.
22. Generate invoice.
23. Save invoice as PDF.
24. View sales history.
25. View daily report.
26. Check low-stock products.
27. Record an expense.
28. Check estimated profit.
29. Create database backup.
30. Close application.
31. Restart application without Internet.
32. Confirm all data is still present.
33. Restore backup on another installation.
34. Confirm data integrity.

Everything must work without Internet.

---

# 51. FINAL PRODUCT GOAL

The final application should feel like:

> **"A beautiful little business assistant that happens to be a POS."**

It should NOT feel like complicated enterprise software.

A shop owner who has never used POS software should be able to understand it immediately.

The most important priorities are:

1. **Ease of use**
2. **Offline reliability**
3. **Fast sales**
4. **Beautiful interface**
5. **Inventory accuracy**
6. **Professional receipts/invoices**
7. **Local business practicality**
8. **Backup/data safety**
9. **Extensibility**
10. **Performance**

Build the system as a real production-quality application, not a UI prototype.

Do not use fake buttons.

Do not leave important features as TODOs.

All core flows must actually work with the local database.

Where a hardware integration cannot be tested in the development environment, create a clean abstraction/interface and a working Windows-compatible implementation path, plus a test/mock printer mode.

At the end, provide:

* Complete source code
* Database schema
* Setup instructions
* Windows build instructions
* Windows installer instructions
* Sample Excel import template
* Sample CSV import template
* User guide
* Architecture documentation
* Test checklist
* Backup/restore documentation

The application name can be:

**EasyPOS**

with the subtitle:

**Votre caisse, simplement. ❤️**

Make the branding easy to change later.
