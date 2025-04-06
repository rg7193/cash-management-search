import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

export interface SearchRequest {
  query: string;
  page?: number;
  size?: number;
  includePayments?: boolean;
  includeDeposits?: boolean;
  includeLoans?: boolean;
}

export interface SearchResult {
  entityType: string;
  entityId: number;
  primaryIdentifier: string;
  date: string;
  amount: number;
  currency: string;
  status: string;
  partyInfo: string;
  description: string;
  referenceNumber: string;
  rank: number;
}

export interface SearchResponse {
  content: SearchResult[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

export interface AutocompleteSuggestion {
  suggestion: string;
  source: string;
}

export interface AutocompleteResponse {
  suggestions: AutocompleteSuggestion[];
  originalQuery: string;
}

export interface SpellingSuggestion {
  suggestion: string;
  similarity: number;
}

export interface SpellingCorrectionResponse {
  suggestions: SpellingSuggestion[];
  originalQuery: string;
}

const searchApi = {
  search: async (request: SearchRequest): Promise<SearchResponse> => {
    const response = await axios.post(`${API_BASE_URL}/search`, request);
    return response.data;
  },

  autocomplete: async (prefix: string, limit: number = 10): Promise<AutocompleteResponse> => {
    const response = await axios.get(`${API_BASE_URL}/search/autocomplete`, {
      params: { prefix, limit }
    });
    return response.data;
  },

  spellingSuggestions: async (term: string, limit: number = 5): Promise<SpellingCorrectionResponse> => {
    const response = await axios.get(`${API_BASE_URL}/search/spelling`, {
      params: { term, limit }
    });
    return response.data;
  },

  fuzzySearch: async (query: string, threshold: number = 0.3): Promise<SearchResult[]> => {
    const response = await axios.get(`${API_BASE_URL}/search/fuzzy`, {
      params: { query, threshold }
    });
    return response.data;
  }
};

export default searchApi;
