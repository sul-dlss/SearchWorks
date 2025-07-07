import { Controller } from "@hotwired/stimulus"
import * as React from 'react'
import { createRoot } from 'react-dom/client';
import Select from '@mui/material/Select';
import Checkbox from '@mui/material/Checkbox';
import FormControl from '@mui/material/FormControl';
import MenuItem from '@mui/material/MenuItem';
import Autocomplete from '@mui/material/Autocomplete';
import TextField from '@mui/material/TextField';

const SearchContext = React.createContext({});
const SearchDispatchContext = React.createContext(null);

const icon = <i className="bi bi-square" />;
const checkedIcon = <i className="bi bi-check-square" />;

const Button = ({ children, onClick, ...props }) => {

  const handleClick = (e) => {
    e.preventDefault();

    if (onClick) onClick(e);
  }

  return (
    <button {...props} onClick={handleClick}>
      {children}
    </button>
  );
}

const formReducer = (state, action) => {
  switch (action.type) {
    case 'addSearchField':
      const searchFieldDefaults = {
        field: state.searchFieldOptions[0]?.field || '',
        type: state.searchTypeOptions[0]?.field || 'must',
        value: ''
      };
      return {
        ...state,
        searchFields: [...state.searchFields, { ...searchFieldDefaults, id: state.currentId + 1, ...action.field }],
        currentId: state.currentId + 1
      };
    case 'removeSearchField':
      return {
        ...state,
        searchFields: state.searchFields.filter((field) => field.id !== action.id)
      };
    case 'updateSearchField':
      return {
        ...state,
        searchFields: state.searchFields.map((field) =>
          field.id === action.id ? { ...field, ...action.data } : field
        )
      };
    case 'addFilterField':
      const filterFieldDefaults = {
        type: state.filterTypeOptions[0]?.field || 'and',
        values: []
      };
      return {
        ...state,
        filterFields: [...state.filterFields, { ...filterFieldDefaults, ...action.data, id: state.currentId + 1 }],
        currentId: state.currentId + 1
      };
    case 'removeFilterField':
      return {
        ...state,
        filterFields: state.filterFields.filter((field) => field.id !== action.id)
      };
    case 'updateFilterField':
      return {
        ...state,
        filterFields: state.filterFields.map((field) =>
          field.id === action.id ? { ...field, ...action.data } : field
        )
      };
    }
  };

const mapBlacklightQueryParamsToForm = (queryParams) => {
  let currentId = 0;
  const formData = {};

  if (queryParams.clause) {
    formData.searchFields = Object.entries(queryParams.clause).map(([_idx, clause]) => {
      return {
        id: currentId++,
        field: clause.field || '',
        type: clause.op || 'must',
        value: clause.query || ''
      };
    });
  }

  if (queryParams.f) {
    formData.filterFields = Object.entries(queryParams.f).map(([field, values]) => {
      return {
        id: currentId++,
        field: field,
        type: 'and',
        values: values
      };
    });
  }

  if (queryParams.f_inclusive) {
    formData.filterFields = Object.entries(queryParams.f_inclusive).map(([field, values]) => {
      return {
        id: currentId++,
        field: field,
        type: 'or',
        values: values
      };
    });
  }

  formData.currentId = currentId;

  return formData;
}


const AdvancedSearchForm = ({ filterFields, queryParams, searchFieldOptions }) => {
  const initialData = {
    filterFields: [],
    filterFieldOptions: filterFields || [],
    filterTypeOptions: [
      { field: 'and', label: 'Includes all (AND)' },
      { field: 'or', label: 'Includes any (OR)' },
    ],
    currentId: 0,
    searchFields: [{ id: 0, field: searchFieldOptions[0]?.field || '', type: 'must', value: queryParams.q || '' }],
    searchFieldOptions: searchFieldOptions || [],
    searchTypeOptions: [
      { field: 'must', label: 'Contains all (AND)'},
      { field: 'should', label: 'Contains any (OR)' }
    ],
    ...(mapBlacklightQueryParamsToForm(queryParams, { filterFields, searchFields: searchFieldOptions }) || {})
  }

  const [form, dispatch] = React.useReducer(formReducer, initialData);

  return (
    <SearchContext value={form}>
      <SearchDispatchContext value={dispatch}>
        <SearchFields />
        <FilterFields />
        <div className="d-flex flex-row justify-content-end gap-3">
          <Button className="btn btn-outline-primary">Reset</Button>
          <Button className="btn btn-primary" type="submit">Search</Button>
        </div>

        <HiddenInputFields />
      </SearchDispatchContext>
    </SearchContext>
  );
}

const HiddenInputFields = () => {
  const context = React.useContext(SearchContext);

  return (
    <>
      {context.searchFields.map((field) => field.value && (
        <>
          <input type="hidden" name={`clause[${field.id}][field]`} value={field.field} key={`${field.id}_field`} />
          <input type="hidden" name={`clause[${field.id}][op]`} value={field.type} key={`${field.id}_type`} />
          <input type="hidden" name={`clause[${field.id}][query]`} value={field.value} key={`${field.id}_value`}/>
        </>
      ))}
      { context.filterFields.map((field) => {
        if (!field.values || field.values.length === 0) return;
        if (field.type === 'and') {
          return (
              field.values.map((value) => (
                <input type="hidden" name={`f[${field.field}][]`} value={value} key={`${field.field}_${value}`}/>
              ))
          )
        } else {
          return (
            field.values.map((value) => (
                <input type="hidden" name={`f_inclusive[${field.field}][]`} value={value} key={`${field.field}_${value}`} />
              ))
          )
        }
      })}
    </>
  );
}

const SearchFields = () => {
  const context = React.useContext(SearchContext);
  const dispatch = React.useContext(SearchDispatchContext);

  const searchFields = context.searchFields;
  const addField = (e) => {
    dispatch({ type: 'addSearchField' });
  }

  return (
    <section className="mb-5">
      <h2>Search</h2>
      {searchFields.map((field) => (
        <SearchField {...field} removeField={searchFields.length > 1 && (() => {
          dispatch({ type: 'removeSearchField', id: field.id });
        })} key={field.id} />
      ))}
      <Button className="btn btn-outline-primary" onClick={addField}>Add search terms</Button>
    </section>
  );
};

const SearchField = ({ field, id, type, value, removeField }) => {
  const context = React.useContext(SearchContext);
  const dispatch = React.useContext(SearchDispatchContext);

  return (
    <div className="d-flex flex-row mb-3 gap-3 align-items-center">
      <FormControl sx={{ minWidth: 120 }} size="small">
        <Select className="w-auto" value={field} onChange={(event) => dispatch({ type: 'updateSearchField', id: id, data: { field: event.target.value } })}>
          {context.searchFieldOptions.map((option) => (
            <MenuItem key={option.field} value={option.field}>
              {option.label}
            </MenuItem>
          ))}
        </Select>
      </FormControl>
      <FormControl sx={{ minWidth: 200 }} size="small">
        <Select className="w-auto" value={type} onChange={(event) => dispatch({ type: 'updateSearchField', id: id, data: { type: event.target.value } })}>
          {context.searchTypeOptions.map((option) => (
            <MenuItem key={option.field} value={option.field}>
              {option.label}
            </MenuItem>
          ))}
        </Select>
      </FormControl>
      <TextField fullWidth size="small" value={value} onChange={(e) => dispatch({ type: 'updateSearchField', id: id, data: { value: e.target.value } })} />
      { removeField && (<Button className="btn btn-outline-danger text-nowrap" onClick={removeField}>Delete row</Button>) }
    </div>
  );
};

const FilterFields = () => {
  const context = React.useContext(SearchContext);
  const dispatch = React.useContext(SearchDispatchContext);


  const filterFields = context.filterFields;
  const addFilterField = (field) => {
    dispatch({ data: { field: field }, type: 'addFilterField' });
  }

  return (
    <section className="mb-5">
      <h2>Filters</h2>
      { filterFields.map((field) => (
        <FilterField key={field.id} id={field.id} {...field} removeField={() => {
          dispatch({ type: 'removeFilterField', id: field.id });
        }}/>
      )) }
      
      <div className="dropdown">
        <Button className="btn btn-outline-primary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">Add filter</Button>
        <ul className="dropdown-menu">
        {context.filterFieldOptions.map((option) => (
          <li key={option.field}>
            <Button className="dropdown-item" onClick={() => addFilterField(option.field)}>{option.label}</Button>
          </li>
          ))}
        </ul>
      </div>
    </section>
  )
}

const FilterField = ({ id, type, values, field, removeField }) => {
  const context = React.useContext(SearchContext);
  const dispatch = React.useContext(SearchDispatchContext);
  const fieldConfig = context.filterFieldOptions.find(f => f.field === field) || {};

  const initialOptions = fieldConfig.values.map((value) => { return value.value });
  const [options, setOptions] = React.useState(initialOptions);
  const [loading, setLoading] = React.useState(false);

  const dataOptions = {};

  if (fieldConfig.values.length == 0 || (fieldConfig.limit && fieldConfig.values.length > fieldConfig.limit)) {
    dataOptions.loading = loading
    dataOptions.filterOptions= (x) => x;
    dataOptions.onInputChange = (event, newInputValue) => {
      (async () => {
        setLoading(true);
        const response = await fetch(`/catalog/facet/${field}?${new URLSearchParams({ 'facet.sort': 'index', query_fragment: newInputValue}).toString() }`, { headers: { 'Accept': 'application/json' } });

        if (response.ok) {
          const json = await response.json();
          setOptions(json.response.facets.items.map(v => v.value));
          setLoading(false);
        }
      })();
    }
    dataOptions.onOpen = () => {
      if (options.length > 0 || loading) return;

      dataOptions.onInputChange(null, '');
    };
  }

  return (
    <div className="d-flex flex-row mb-3 gap-3 align-items-start">
      <span className="fw-semibold text-nowrap mt-2">{fieldConfig.label}</span>

      <FormControl sx={{ minWidth: 200 }} size="small">
        <Select className="w-auto text-nowrap" value={type} onChange={(event) => dispatch({ type: 'updateFilterField', id: id, data: { type: event.target.value } })}>
          {context.filterTypeOptions.map((option) => (
            <MenuItem key={option.field} value={option.field}>
              {option.label}
            </MenuItem>
          ))}
        </Select>
      </FormControl>
      <Autocomplete
        size="small"
        multiple
        limitTags={2}
        onChange={(event, newValue) => { dispatch({ type: 'updateFilterField', id: id, data: { values: newValue } })} }
        options={options}
        value={values}
        renderOption={(props, option, { selected }) => {
          const { key, ...optionProps } = props;
          return (
            <li key={key} {...optionProps} className='p-0'>
              <Checkbox
                icon={icon}
                checkedIcon={checkedIcon}
                style={{ marginRight: 8 }}
                checked={selected}
              />
              {option}
            </li>
          );
        }}
        renderInput={(params) => (
          <TextField {...params} placeholder="Select values" />
        )}
        sx={{ width: '500px' }}
        {...(dataOptions)}
      />
      { removeField && (<Button className="btn btn-outline-danger text-nowrap" onClick={removeField}>Delete row</Button>) }
    </div>
  );
};


export default class extends Controller {
  static values = {
    filterFields: Array,
    queryParams: Object,
    searchFieldOptions: Array
  }
  connect() {
    createRoot(this.element).render(<AdvancedSearchForm queryParams={this.queryParamsValue} searchFieldOptions={this.searchFieldOptionsValue} filterFields={this.filterFieldsValue} />);
  }
}
