import { Controller } from "@hotwired/stimulus"
import * as React from 'react'
import { createRoot } from 'react-dom/client';
import Select from '@mui/material/Select';
import InputLabel from '@mui/material/InputLabel';
import Checkbox from '@mui/material/Checkbox';
import FormControl from '@mui/material/FormControl';
import MenuItem from '@mui/material/MenuItem';
import Autocomplete from '@mui/material/Autocomplete';
import TextField from '@mui/material/TextField';
import Chip from '@mui/material/Chip';
import { createTheme, ThemeProvider } from '@mui/material/styles';

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

const AddButton = ({ children, className, ...props }) => (
  <Button className={`btn icon-link text-nowrap ${className}`} {...props}><i class="bi bi-plus-square-fill text-digital-green" aria-hidden></i>{children}</Button>
)

const DeleteButton = ({ children, className, ...props }) => (
  <Button className={`btn icon-link text-nowrap ${className}`} {...props} ariaLabel={children}><i class="bi bi-dash-square-fill text-digital-red-light" aria-hidden></i><span class="d-none d-md-inline">{children}</span></Button>
)

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
    case 'reset':
      return {
        ...state,
        searchFields: [{ id: 0, field: state.searchFieldOptions[0]?.field || '', type: 'must', value: '' }],
        filterFields: state.filterFieldOptions.filter(f => f.top).map((f, i) => ({
          id: i + 1, field: f.field, type: 'and', values: []
        })),
        currentId: state.filterFieldOptions.filter(f => f.top).length
      };
    }
  };

const mapBlacklightQueryParamsToForm = (queryParams, defaultData) => {
  let currentId = defaultData.currentId;
  const searchFieldKeys = defaultData.searchFieldOptions.map(f => f.field);
  const filterFieldKeys = defaultData.filterFieldOptions.map(f => f.field);

  const formData = {};

  if (queryParams.clause) {
    formData.searchFields = Object.entries(queryParams.clause).filter(([_idx, clause]) => searchFieldKeys.includes(clause.field)).map(([_idx, clause]) => {
      return {
        id: currentId++,
        field: clause.field || '',
        type: clause.op || 'must',
        value: clause.query || ''
      };
    });
  }

  let filterFields = [];

  if (queryParams.f) {
    const f = Object.entries(queryParams.f).filter(([field, _values]) => filterFieldKeys.includes(field)).map(([field, values]) => {
      return {
        id: currentId++,
        field: field,
        type: 'and',
        values: values
      };
    });

    filterFields = filterFields.concat(f);
  }

  if (queryParams.f_inclusive) {
    const f_inclusive = Object.entries(queryParams.f_inclusive).filter(([field, _values]) => filterFieldKeys.includes(field)).map(([field, values]) => {
      return {
        id: currentId++,
        field: field,
        type: 'or',
        values: values
      };
    });
    filterFields = filterFields.concat(f_inclusive);
  }

  if (queryParams.range) {
    const range = Object.entries(queryParams.range).filter(([field, _values]) => filterFieldKeys.includes(field)).map(([field, range]) => {
      return {
        id: currentId++,
        field: field,
        values: [range.begin || '', range.end || '']
      };
    });
    filterFields = filterFields.concat(range);
  }

  if (filterFields.length > 0) {
    formData.filterFields = filterFields;
  }

  formData.currentId = currentId;

  return formData;
}

const preventFormSubmit = (e) => {
  if (e.key === 'Enter') e.preventDefault();
}

const AdvancedSearchForm = ({ filterFields, queryParams, searchFieldOptions }) => {
  const initialData = {
    filterFields: filterFields.filter(f => f.top).map((f, i) => ({
      id: i + 2, field: f.field, type: 'and', values: []
    })),
    filterFieldOptions: filterFields || [],
    filterTypeOptions: [
      { field: 'and', label: 'Includes all' },
      { field: 'or', label: 'Includes any' },
      { field: 'not', label: 'Excludes all' }
    ],
    currentId: filterFields.filter(f => f.top).length,
    searchFields: [
      { id: 0, field: searchFieldOptions[0]?.field || '', type: 'must', value: queryParams.q || '' },
      { id: 1, field: searchFieldOptions[0]?.field || '', type: 'must', value: '' }
    ],
    searchFieldOptions: searchFieldOptions || [],
    searchTypeOptions: [
      { field: 'must', label: 'Contains all'},
      { field: 'should', label: 'Contains any' }
    ]
  }

  const resetForm = (e) => {
    dispatch({ type: 'reset' });
  }

  const [form, dispatch] = React.useReducer(formReducer, { ...initialData, ...mapBlacklightQueryParamsToForm(queryParams, initialData) });

  return (
    <SearchContext value={form}>
      <SearchDispatchContext value={dispatch}>
        <SearchFields />
        <FilterFields />
        <div className="d-flex flex-row justify-content-end gap-3">
          <Button className="btn btn-outline-primary" onClick={resetForm}>Reset</Button>
          <input className="btn btn-primary" type="submit" value="Search" />
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
      {context.searchFields.map((field) => field.value?.length > 0 && (
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
        } else if (field.type === 'not') {
          return (
            field.values.map((value) => (
                <input type="hidden" name={`f[-${field.field}][]`} value={value} key={`${field.field}_${value}`} />
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
    <section className="mb-5 query-criteria">
      <h2>Search</h2>
      {searchFields.map((field) => (
        <SearchField {...field} removeField={searchFields.length > 1 && (() => {
          dispatch({ type: 'removeSearchField', id: field.id });
        })} key={field.id} />
      ))}
      <AddButton onClick={addField}>Add search terms</AddButton>
    </section>
  );
};

const SearchField = ({ field, id, type, value, removeField }) => {
  const context = React.useContext(SearchContext);
  const dispatch = React.useContext(SearchDispatchContext);
  const searchField = context.searchFieldOptions.find(f => f.field === field) || {};

  return (
    <fieldset className="d-flex flex-row mb-3 gap-3 align-items-center">
      <legend className="visually-hidden">Search query</legend>
      <FormControl className="col-4 col-sm-3 col-lg-2 col-xl-3" size="small">
        <InputLabel id={`search-field-select-${id}`} className="visually-hidden">Search in</InputLabel>
        <Select labelId={`search-field-select-${id}`} className="w-auto search-field" value={field} onChange={(event) => dispatch({ type: 'updateSearchField', id: id, data: { field: event.target.value } })}>
          {context.searchFieldOptions.map((option) => (
            <MenuItem key={option.field} value={option.field}>
              {option.label}
            </MenuItem>
          ))}
        </Select>
      </FormControl>
      <FormControl className="col-4 col-sm-3 col-lg-2 col-xl-3" size="small">
        <InputLabel id={`search-field-operator-${id}`} className="visually-hidden">{searchField?.label} search operator</InputLabel>
        <Select labelId={`search-field-operator-${id}`} className="w-auto" value={type} onChange={(event) => dispatch({ type: 'updateSearchField', id: id, data: { type: event.target.value } })}>
          {context.searchTypeOptions.map((option) => (
            <MenuItem key={option.field} value={option.field}>
              {option.label}
            </MenuItem>
          ))}
        </Select>
      </FormControl>
      <label className="visually-hidden" htmlFor={`search-field-${id}`}>{searchField?.label} search term</label>
      <TextField id={`search-field-${id}`} fullWidth size="small" value={value} onKeyDown={preventFormSubmit} onChange={(e) => dispatch({ type: 'updateSearchField', id: id, data: { value: e.target.value } })} />
      { removeField && (<DeleteButton onClick={removeField}>Delete row</DeleteButton>) }
    </fieldset>
  );
};

const FilterFields = () => {
  const context = React.useContext(SearchContext);
  const dispatch = React.useContext(SearchDispatchContext);


  const filterFields = context.filterFields;
  const usedFilterFieldKeys = filterFields.map((f) => f.field);
  const addFilterField = (field) => {
    dispatch({ data: { field: field }, type: 'addFilterField' });
  }

  return (
    <section className="mb-5 limit-criteria">
      <h2>Filters</h2>
      { filterFields.map((field) => (
        <FilterField key={field.id} id={field.id} {...field} removeField={() => {
          dispatch({ type: 'removeFilterField', id: field.id });
        }}/>
      )) }
      
      <div className="dropdown">
        <AddButton className="border border-dark-subtle dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">Add filter</AddButton>
        <ul className="dropdown-menu">
        {context.filterFieldOptions.map((option) => (
          (!usedFilterFieldKeys.includes(option.field)) && (<li key={option.field}>
            <Button className="dropdown-item" onClick={() => addFilterField(option.field)}>{option.label}</Button>
          </li>)
          ))}
        </ul>
      </div>
    </section>
  )
}

const FilterField = ({ field, removeField, ...args }) => {
  const context = React.useContext(SearchContext);
  const fieldConfig = context.filterFieldOptions.find(f => f.field === field) || {};
  const id = args.id;

  if (fieldConfig.range) {
    return (
      <fieldset className="d-flex flex-row mb-3 gap-3 align-items-start">
        <legend className="visually-hidden">Filter field</legend>
        <span className="fw-semibold text-nowrap mt-2 col-4 col-sm-3 col-lg-2">{fieldConfig.label}</span>
        <RangeFilterField field={field} {...args} />
        { removeField && (<DeleteButton className="ms-auto" onClick={removeField}>Delete row</DeleteButton>) }
      </fieldset>
    );
  } else {
    return (
      <fieldset className="d-flex flex-row mb-3 gap-3 align-items-start">
        <legend className="visually-hidden">Filter field</legend>
        <label htmlFor={`filter-field-${id}`} className="fw-semibold text-nowrap mt-2 col-4 col-sm-3 col-lg-2">{fieldConfig.label}</label>
        <AutocompleteFilterField field={field} {...args} />
        { removeField && (<DeleteButton onClick={removeField}>Delete row</DeleteButton>) }
      </fieldset>
    );
  }
};

const RangeFilterField = ({ id, field, values }) => {
  const context = React.useContext(SearchContext);
  const dispatch = React.useContext(SearchDispatchContext);

  return (
    <>
      <label className="visually-hidden" htmlFor={`range-field-${id}-begin`}>From year</label>
      <TextField className="col-4 col-sm-3 col-lg-2 col-xl-3" placeholder="From year" id={`range-field-${id}-begin`} name={values[0] && values[0].length > 0 && `range[${field}][begin]`} value={values[0] || ''} onKeyDown={preventFormSubmit} onChange={(event) => { dispatch({ type: 'updateFilterField', id: id, data: { values: [event.target.value, values[1]] } })}} size="small"></TextField>
      <label className="visually-hidden" htmlFor={`range-field-${id}-end`}>To year</label>
      <TextField sx={{ minWidth: '8ch' }} className="col-md-3 col-lg-2 col-xl-3" placeholder="To year" id={`range-field-${id}-end`} name={values[1] && values[1].length > 0 && `range[${field}][end]`} value={values[1] || ''} onKeyDown={preventFormSubmit} onChange={(event) => { dispatch({ type: 'updateFilterField', id: id, data: { values: [values[0], event.target.value] } })}} size="small"></TextField>
    </>
  );
}

const AutocompleteFilterField = ({ id, type, values, field }) => {
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
        const response = await fetch(`/catalog/facet/${field}?${new URLSearchParams({ 'facet.sort': 'count', query_fragment: newInputValue}).toString() }`, { headers: { 'Accept': 'application/json' } });

        if (response.ok) {
          const json = await response.json();
          setOptions(json.response.facets.items.map(v => v.value).sort());
          setLoading(false);
        }
      })();
    }
    dataOptions.onOpen = () => {
      if (options.length > 0 || loading) return;

      dataOptions.onInputChange(null, '');
    };
  }

  const mapValueToLabel = (value) => {
    return (fieldConfig.value_labels[value] || value).replaceAll('|', ' > ');
  }

  return (
    <>
      <FormControl className="col-4 col-sm-3 col-lg-2 col-xl-3" size="small">
        <InputLabel id={`filter-field-operator-${id}`} className="visually-hidden">Search operator</InputLabel>
        <Select labelId={`filter-field-operator-${id}`} className="w-auto text-nowrap" value={type} onChange={(event) => dispatch({ type: 'updateFilterField', id: id, data: { type: event.target.value } })}>
          {context.filterTypeOptions.map((option) => (
            <MenuItem key={option.field} value={option.field}>
              {option.label}
            </MenuItem>
          ))}
        </Select>
      </FormControl>
      <Autocomplete
        multiple
        disablePortal
        limitTags={2}
        size="small"
        id={`filter-field-${id}`}
        options={options}
        onChange={(event, newValue) => { dispatch({ type: 'updateFilterField', id: id, data: { values: newValue } })} }
        value={values}
        disableCloseOnSelect
        getOptionLabel={mapValueToLabel}
        popupIcon={
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-chevron-down" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708"/>
          </svg>
        }
        renderOption={(props, option, { selected }) => {
          const { key, ...optionProps } = props;
          return (
            <li key={key} {...optionProps} className={`p-0 ${optionProps.className}`}>
              <Checkbox
                id={key}
                icon={icon}
                checkedIcon={checkedIcon}
                style={{ marginRight: 8 }}
                checked={selected}
              />
              <label htmlFor={key} onClick={e => e.preventDefault()}>{mapValueToLabel(option)}</label>
            </li>
          );
        }}
        renderTags={(tagValue, getTagProps) =>
          tagValue.map((option, index) => (
            <Chip
              key={index}
              label={mapValueToLabel(option)}
              {...getTagProps({ index })}
              deleteIcon={
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="btn remove" viewBox="0 0 16 16">
                  <path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708"/>
                </svg>
              }
              size="small"
              sx={{ fontSize: '0.875rem' }}
            />
          ))
        }
        style={{ width: 500 }}
        renderInput={(params) => (
          <TextField onKeyDown={preventFormSubmit} {...params} placeholder="Select values" />
        )}
        {...(dataOptions)}
       />
    </>
  );
};

const SulSelectDropdownIcon = (props) => (
  <svg
    {...props}
    width="16"
    height="16"
    fill="currentColor"
    viewBox="0 0 16 16"
  >
    <path fill-rule="evenodd" d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708"/>
  </svg>
);

const theme = createTheme({
  typography: {
    color: 'var(--stanford-black)',
    fontFamily: '"Source Sans 3"',
  },
  components: {
    MuiChip: {
      styleOverrides: {
        label: {
          padding: '0.5rem 0.75rem',
        },
        deleteIcon: {
          color: 'var(--stanford-black)',
          '&:hover': {
            color: 'var(--stanford-digital-red)',
          },
        },
      },
    },
    MuiMenuItem: {
      styleOverrides: {
        root: {
          '&.Mui-selected': {
            backgroundColor: 'white',
            '&:hover': {
              backgroundColor: 'var(--bs-dropdown-link-hover-bg)',
            },
          },
        },
      },
    },
    MuiSelect: {
      defaultProps: {
        IconComponent: SulSelectDropdownIcon,
      },
      styleOverrides: {
        root: {
          '&.Mui-selected': {
            backgroundColor: 'white',
            '&:hover': {
              backgroundColor: 'var(--bs-dropdown-link-hover-bg)',
            },
          },
        },
      },
    },
  },
});

export default class extends Controller {
  static values = {
    filterFields: Array,
    queryParams: Object,
    searchFieldOptions: Array
  }
  connect() {
    createRoot(this.element).render(<ThemeProvider theme={theme}>
                                      <AdvancedSearchForm queryParams={this.queryParamsValue}
                                                          searchFieldOptions={this.searchFieldOptionsValue}
                                                          filterFields={this.filterFieldsValue} />
                                    </ThemeProvider>);
  }
}
