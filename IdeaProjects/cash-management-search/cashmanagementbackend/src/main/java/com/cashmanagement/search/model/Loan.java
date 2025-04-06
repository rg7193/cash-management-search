package com.cashmanagement.search.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "loans", schema = "cash_management")
public class Loan {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "loan_id")
    private Long loanId;
    
    @Column(name = "account_id", nullable = false)
    private String accountId;
    
    @Column(name = "loan_date", nullable = false)
    private LocalDateTime loanDate;
    
    @Column(name = "principal_amount", nullable = false)
    private BigDecimal principalAmount;
    
    @Column(nullable = false)
    private String currency;
    
    @Column(name = "interest_rate", nullable = false)
    private BigDecimal interestRate;
    
    @Column(name = "term_months", nullable = false)
    private Integer termMonths;
    
    @Column(name = "payment_frequency", nullable = false)
    private String paymentFrequency;
    
    @Column(nullable = false)
    private String status;
    
    @Column(name = "borrower_name", nullable = false)
    private String borrowerName;
    
    private String purpose;
    
    private String collateral;
    
    @Column(name = "reference_number")
    private String referenceNumber;
    
    @Column(name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    @Column(name = "search_vector", columnDefinition = "tsvector")
    private String searchVector;
}
