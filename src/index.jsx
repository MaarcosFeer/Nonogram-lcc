import React from 'react';
import * as ReactDOMClient from 'react-dom/client';
import './index.css';
import PrincipalPage from './PrincipalPage';

ReactDOMClient.createRoot(document.getElementById('root'))
  .render(<PrincipalPage/>);
