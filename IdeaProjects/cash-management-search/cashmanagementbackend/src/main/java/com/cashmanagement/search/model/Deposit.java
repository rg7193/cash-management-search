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
@Table(name = "deposits", schema = "cash_management")
public class Deposit {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "deposit_id")
    private Long depositId;
    
    @Column(name = "account_id", nullable = false)
    private String accountId;
    
    @Column(name = "deposit_date", nullable = false)
    private LocalDateTime depositDate;
    
    @Column(nullable = false)
    private BigDecimal amount;
    
    @Column(nullable = false)
    private String currency;
    
    @Column(name = "deposit_type", nullable = false)
    private String depositType;
    
    @Column(nullable = false)
    private String status;
    
    @Column(name = "term_days")
    private Integer termDays;
    
    @Column(name = "interest_rate")
    private BigDecimal interestRate;
    
    @Column(name = "maturity_date")
    private LocalDateTime maturityDate;
    
    @Column(name = "auto_renew")
    private Boolean autoRenew;
    
    @Column(name = "depositor_name", nullable = false)
    private String depositorName;
    
    private String description;
    
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
