package com.cashmanagement.search.repository;

import com.cashmanagement.search.dto.AutocompleteResponse.AutocompleteSuggestion;
import com.cashmanagement.search.dto.SearchResultDTO;
import com.cashmanagement.search.dto.SpellingCorrectionResponse.SpellingSuggestion;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Repository
public class SearchRepository {

    @PersistenceContext
    private EntityManager entityManager;

    public Page<SearchResultDTO> fullTextSearch(String searchTerm, Pageable pageable) {
        String countQuery = "SELECT COUNT(*) FROM cash_management.search_all(:searchTerm)";
        Query query = entityManager.createNativeQuery(countQuery);
        query.setParameter("searchTerm", searchTerm);
        Long total = ((Number) query.getSingleResult()).longValue();

        String searchQuery = "SELECT * FROM cash_management.search_all(:searchTerm) " +
                "ORDER BY rank DESC " +
                "LIMIT :limit OFFSET :offset";
        
        Query searchNativeQuery = entityManager.createNativeQuery(searchQuery);
        searchNativeQuery.setParameter("searchTerm", searchTerm);
        searchNativeQuery.setParameter("limit", pageable.getPageSize());
        searchNativeQuery.setParameter("offset", pageable.getOffset());

        List<Object[]> results = searchNativeQuery.getResultList();
        List<SearchResultDTO> searchResults = new ArrayList<>();

        for (Object[] result : results) {
            SearchResultDTO dto = new SearchResultDTO();
            dto.setEntityType((String) result[0]);
            dto.setEntityId(((Number) result[1]).longValue());
            dto.setPrimaryIdentifier((String) result[2]);
            dto.setDate(((Timestamp) result[3]).toLocalDateTime());
            dto.setAmount(new BigDecimal(result[4].toString()));
            dto.setCurrency((String) result[5]);
            dto.setStatus((String) result[6]);
            dto.setPartyInfo((String) result[7]);
            dto.setDescription((String) result[8]);
            dto.setReferenceNumber((String) result[9]);
            dto.setRank(((Number) result[10]).floatValue());
            searchResults.add(dto);
        }

        return new PageImpl<>(searchResults, pageable, total);
    }

    public List<AutocompleteSuggestion> getAutocompleteSuggestions(String prefix, int limit) {
        String query = "SELECT * FROM cash_management.autocomplete(:prefix, :limit)";
        Query nativeQuery = entityManager.createNativeQuery(query);
        nativeQuery.setParameter("prefix", prefix);
        nativeQuery.setParameter("limit", limit);

        List<Object[]> results = nativeQuery.getResultList();
        List<AutocompleteSuggestion> suggestions = new ArrayList<>();

        for (Object[] result : results) {
            AutocompleteSuggestion suggestion = new AutocompleteSuggestion();
            suggestion.setSuggestion((String) result[0]);
            suggestion.setSource((String) result[1]);
            suggestions.add(suggestion);
        }

        return suggestions;
    }

    public List<SpellingSuggestion> getSpellingSuggestions(String misspelledTerm, int limit) {
        String query = "SELECT * FROM cash_management.spelling_suggestions(:misspelledTerm, :limit)";
        Query nativeQuery = entityManager.createNativeQuery(query);
        nativeQuery.setParameter("misspelledTerm", misspelledTerm);
        nativeQuery.setParameter("limit", limit);

        List<Object[]> results = nativeQuery.getResultList();
        List<SpellingSuggestion> suggestions = new ArrayList<>();

        for (Object[] result : results) {
            SpellingSuggestion suggestion = new SpellingSuggestion();
            suggestion.setSuggestion((String) result[0]);
            suggestion.setSimilarity(((Number) result[1]).floatValue());
            suggestions.add(suggestion);
        }

        return suggestions;
    }

    public List<SearchResultDTO> fuzzySearch(String searchTerm, float similarityThreshold) {
        String query = "SELECT * FROM cash_management.fuzzy_search(:searchTerm, :similarityThreshold)";
        Query nativeQuery = entityManager.createNativeQuery(query);
        nativeQuery.setParameter("searchTerm", searchTerm);
        nativeQuery.setParameter("similarityThreshold", similarityThreshold);

        List<Object[]> results = nativeQuery.getResultList();
        List<SearchResultDTO> searchResults = new ArrayList<>();

        for (Object[] result : results) {
            SearchResultDTO dto = new SearchResultDTO();
            dto.setEntityType((String) result[0]);
            dto.setEntityId(((Number) result[1]).longValue());
            dto.setPrimaryIdentifier((String) result[2]);
            dto.setRank(((Number) result[3]).floatValue()); // Using rank for similarity
            searchResults.add(dto);
        }

        return searchResults;
    }
}
