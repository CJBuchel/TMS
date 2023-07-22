extern crate proc_macro;

use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, ItemFn};

#[proc_macro_attribute]
pub fn tms_private_route(_attr: TokenStream, item: TokenStream) -> TokenStream {
  let mut function = parse_macro_input!(item as ItemFn);

  // Add parameters to function
  function.sig.inputs.push(syn::parse_quote!(security: &State<Security>));
  function.sig.inputs.push(syn::parse_quote!(clients: &State<TmsClients>));
  function.sig.inputs.push(syn::parse_quote!(db: &State<std::sync::Arc<TmsDB>>));
  function.sig.inputs.push(syn::parse_quote!(uuid: String));


  TokenStream::from(quote! {
    #function
  })
}