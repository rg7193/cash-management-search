-- Insert sample data for payments
INSERT INTO cash_management.payments (
    transaction_id, payment_date, amount, currency, payment_method, status,
    sender_name, sender_account, recipient_name, recipient_account,
    description, reference_number, category, tags
) VALUES
    ('TRX-001-2025', '2025-01-05 10:30:00', 5000.00, 'USD', 'Wire Transfer', 'Completed',
    'John Smith', 'ACCT-JS-001', 'Alice Johnson', 'ACCT-AJ-002',
    'January office rent payment', 'REF-RENT-JAN', 'Rent', ARRAY['rent', 'office', 'monthly']),
    
    ('TRX-002-2025', '2025-01-10 14:15:00', 1250.75, 'USD', 'ACH', 'Completed',
    'Tech Solutions Inc', 'ACCT-TS-003', 'Cloud Services Co', 'ACCT-CS-004',
    'Monthly cloud hosting services', 'REF-CLOUD-JAN', 'IT Services', ARRAY['cloud', 'hosting', 'monthly']),
    
    ('TRX-003-2025', '2025-01-15 09:45:00', 7500.00, 'USD', 'Wire Transfer', 'Pending',
    'Global Imports LLC', 'ACCT-GI-005', 'Overseas Exports Ltd', 'ACCT-OE-006',
    'Purchase order #12345 - Q1 inventory', 'REF-PO-12345', 'Inventory', ARRAY['inventory', 'purchase', 'quarterly']),
    
    ('TRX-004-2025', '2025-01-20 16:30:00', 3200.50, 'EUR', 'SEPA', 'Completed',
    'European Branch GmbH', 'ACCT-EB-007', 'Main Office Inc', 'ACCT-MO-008',
    'Profit transfer Q4 2024', 'REF-PROFIT-Q4', 'Internal Transfer', ARRAY['profit', 'transfer', 'quarterly']),
    
    ('TRX-005-2025', '2025-01-25 11:20:00', 950.00, 'USD', 'ACH', 'Failed',
    'Marketing Services Co', 'ACCT-MS-009', 'Digital Ads Inc', 'ACCT-DA-010',
    'January social media campaign', 'REF-MKTG-JAN', 'Marketing', ARRAY['marketing', 'social media', 'monthly']),
    
    ('TRX-006-2025', '2025-02-01 13:45:00', 4500.00, 'USD', 'Wire Transfer', 'Completed',
    'John Smith', 'ACCT-JS-001', 'Alice Johnson', 'ACCT-AJ-002',
    'February office rent payment', 'REF-RENT-FEB', 'Rent', ARRAY['rent', 'office', 'monthly']),
    
    ('TRX-007-2025', '2025-02-05 10:15:00', 12500.00, 'USD', 'Wire Transfer', 'Completed',
    'Capital Investments LP', 'ACCT-CI-011', 'Strategic Projects Inc', 'ACCT-SP-012',
    'Project Alpha funding - Phase 1', 'REF-ALPHA-P1', 'Investment', ARRAY['project', 'funding', 'investment']),
    
    ('TRX-008-2025', '2025-02-10 09:30:00', 1800.25, 'USD', 'ACH', 'Completed',
    'HR Solutions LLC', 'ACCT-HR-013', 'Benefits Provider Inc', 'ACCT-BP-014',
    'Employee benefits - February 2025', 'REF-BENEFITS-FEB', 'HR', ARRAY['benefits', 'employees', 'monthly']),
    
    ('TRX-009-2025', '2025-02-15 14:00:00', 6700.00, 'USD', 'Wire Transfer', 'Pending',
    'Retail Division', 'ACCT-RD-015', 'Wholesale Supplier Co', 'ACCT-WS-016',
    'Spring collection inventory purchase', 'REF-SPRING-INV', 'Inventory', ARRAY['inventory', 'seasonal', 'retail']),
    
    ('TRX-010-2025', '2025-02-20 11:45:00', 2300.00, 'USD', 'ACH', 'Completed',
    'Operations Dept', 'ACCT-OD-017', 'Facility Management LLC', 'ACCT-FM-018',
    'February maintenance services', 'REF-MAINT-FEB', 'Maintenance', ARRAY['maintenance', 'facility', 'monthly']);

-- Insert sample data for deposits
INSERT INTO cash_management.deposits (
    account_id, deposit_date, amount, currency, deposit_type, status,
    term_days, interest_rate, maturity_date, auto_renew, depositor_name,
    description, reference_number
) VALUES
    ('ACCT-JS-001', '2025-01-10 09:00:00', 50000.00, 'USD', 'Fixed Term', 'Active',
    90, 3.25, '2025-04-10 09:00:00', FALSE, 'John Smith',
    'Q1 2025 operating reserve', 'DEP-Q1-RESERVE'),
    
    ('ACCT-TS-003', '2025-01-15 10:30:00', 100000.00, 'USD', 'Fixed Term', 'Active',
    180, 3.50, '2025-07-14 10:30:00', TRUE, 'Tech Solutions Inc',
    'H1 2025 tax reserve', 'DEP-H1-TAX'),
    
    ('ACCT-GI-005', '2025-01-20 14:15:00', 75000.00, 'USD', 'Notice', 'Active',
    30, 2.75, '2025-02-19 14:15:00', FALSE, 'Global Imports LLC',
    'Inventory funding reserve', 'DEP-INV-FUND'),
    
    ('ACCT-EB-007', '2025-01-25 11:00:00', 125000.00, 'EUR', 'Fixed Term', 'Active',
    365, 2.90, '2026-01-25 11:00:00', TRUE, 'European Branch GmbH',
    'Annual operating reserve', 'DEP-ANNUAL-EUR'),
    
    ('ACCT-CI-011', '2025-02-01 09:45:00', 500000.00, 'USD', 'Fixed Term', 'Active',
    90, 3.40, '2025-05-02 09:45:00', FALSE, 'Capital Investments LP',
    'Q2 2025 investment fund', 'DEP-Q2-INVEST'),
    
    ('ACCT-RD-015', '2025-02-05 13:30:00', 200000.00, 'USD', 'Overnight', 'Matured',
    1, 2.00, '2025-02-06 13:30:00', FALSE, 'Retail Division',
    'Temporary cash surplus', 'DEP-TEMP-RETAIL'),
    
    ('ACCT-JS-001', '2025-02-10 10:00:00', 25000.00, 'USD', 'Fixed Term', 'Active',
    60, 3.10, '2025-04-11 10:00:00', TRUE, 'John Smith',
    'Short-term savings', 'DEP-SHORT-SAVE'),
    
    ('ACCT-MS-009', '2025-02-15 15:45:00', 40000.00, 'USD', 'Notice', 'Active',
    45, 2.85, '2025-04-01 15:45:00', FALSE, 'Marketing Services Co',
    'Q2 marketing budget reserve', 'DEP-Q2-MKTG'),
    
    ('ACCT-OD-017', '2025-02-20 11:30:00', 60000.00, 'USD', 'Fixed Term', 'Active',
    120, 3.30, '2025-06-20 11:30:00', TRUE, 'Operations Dept',
    'Operations contingency fund', 'DEP-OPS-CONT'),
    
    ('ACCT-BP-014', '2025-02-25 14:00:00', 150000.00, 'USD', 'Fixed Term', 'Active',
    270, 3.60, '2025-11-22 14:00:00', FALSE, 'Benefits Provider Inc',
    'Benefits funding reserve', 'DEP-BEN-FUND');

-- Insert sample data for loans
INSERT INTO cash_management.loans (
    account_id, loan_date, principal_amount, currency, interest_rate, term_months,
    payment_frequency, status, borrower_name, purpose, collateral, reference_number
) VALUES
    ('ACCT-JS-001', '2025-01-15 11:00:00', 250000.00, 'USD', 5.25, 60,
    'Monthly', 'Active', 'John Smith',
    'Office space purchase', 'Commercial property at 123 Business Ave', 'LOAN-OFFICE-2025'),
    
    ('ACCT-TS-003', '2025-01-20 13:30:00', 100000.00, 'USD', 4.75, 36,
    'Monthly', 'Active', 'Tech Solutions Inc',
    'IT infrastructure upgrade', 'Company equipment and accounts receivable', 'LOAN-IT-INFRA'),
    
    ('ACCT-GI-005', '2025-01-25 10:15:00', 500000.00, 'USD', 5.50, 48,
    'Monthly', 'Pending Approval', 'Global Imports LLC',
    'Warehouse expansion', 'Existing warehouse property and inventory', 'LOAN-WAREHOUSE'),
    
    ('ACCT-EB-007', '2025-02-01 09:30:00', 300000.00, 'EUR', 4.25, 60,
    'Quarterly', 'Active', 'European Branch GmbH',
    'European market expansion', 'Parent company guarantee', 'LOAN-EU-EXPAND'),
    
    ('ACCT-MS-009', '2025-02-05 14:45:00', 75000.00, 'USD', 6.00, 24,
    'Monthly', 'Active', 'Marketing Services Co',
    'Digital marketing campaign', 'Company assets and future revenue', 'LOAN-DIGITAL-MKT'),
    
    ('ACCT-RD-015', '2025-02-10 11:30:00', 400000.00, 'USD', 5.75, 48,
    'Monthly', 'Under Review', 'Retail Division',
    'New store locations', 'Existing retail properties', 'LOAN-RETAIL-EXP'),
    
    ('ACCT-SP-012', '2025-02-15 10:00:00', 1000000.00, 'USD', 5.00, 120,
    'Monthly', 'Active', 'Strategic Projects Inc',
    'Research and development center', 'Corporate campus property', 'LOAN-R&D-CENTER'),
    
    ('ACCT-HR-013', '2025-02-20 13:15:00', 50000.00, 'USD', 4.50, 12,
    'Monthly', 'Active', 'HR Solutions LLC',
    'Employee training program', 'Company assets', 'LOAN-TRAINING'),
    
    ('ACCT-WS-016', '2025-02-25 15:30:00', 350000.00, 'USD', 5.25, 36,
    'Monthly', 'Pending Approval', 'Wholesale Supplier Co',
    'Supply chain optimization', 'Inventory and equipment', 'LOAN-SUPPLY-CHAIN'),
    
    ('ACCT-FM-018', '2025-03-01 09:45:00', 200000.00, 'USD', 4.90, 60,
    'Monthly', 'Active', 'Facility Management LLC',
    'Equipment purchase', 'Purchased equipment', 'LOAN-EQUIPMENT');
