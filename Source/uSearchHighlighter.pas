{-----------------------------------------------------------------------------
 Unit Name: uSearchHighlighter
 Author:    Kiriakos Vlahos
 Date:      24-May-2007
 Purpose:   Classes and support routints for highlighting a search term
-----------------------------------------------------------------------------}

unit uSearchHighlighter;

interface

uses
  SynEditTypes,
  SynEditMiscClasses,
  uEditAppIntfs;

procedure RegisterSearchHighlightIndicatorSpec(Editor: IEditor);
procedure HighligthtSearchTerm(ATerm: string; Editor: IEditor;
  SearchEngine: TSynEditSearchCustom; SearchOptions: TSynSearchOptions);
procedure ClearSearchHighlight(Editor: IEditor);
procedure ClearAllHighlightedTerms;

const SearchHighlightIndicatorId: TGUID  = '{A59BCD6A-02A6-4B34-B28C-D9EACA0C9F09}';

implementation

uses
  SynDWrite,
  cPyScripterSettings;

procedure ClearAllHighlightedTerms;
begin
  GI_EditorFactory.ApplyToEditors(procedure(Editor: IEditor)
  begin
    ClearSearchHighlight(Editor);
  end);
end;

procedure RegisterSearchHighlightIndicatorSpec(Editor: IEditor);
const
  Alpha = 0.2;  // could allow customization
begin
  var Spec := TSynIndicatorSpec.New(sisRoundedFilledRectangle, clNoneF,
    D2D1ColorF(PyIDEOptions.HighlightSelectedWordColor, Alpha), []);

  Editor.SynEdit.Indicators.RegisterSpec(SearchHighlightIndicatorId, Spec);
  Editor.SynEdit2.Indicators.RegisterSpec(SearchHighlightIndicatorId, Spec);
end;

procedure ClearSearchHighlight(Editor: IEditor);
begin
  if Editor.HasSearchHighlight then
  begin
    Editor.SynEdit.Indicators.Clear(SearchHighlightIndicatorId);
    Editor.SynEdit2.Indicators.Clear(SearchHighlightIndicatorId);
    Editor.HasSearchHighlight := False;
    Editor.SynEdit.UpdateScrollBars;
    Editor.SynEdit2.UpdateScrollBars;
  end;
end;

procedure HighligthtSearchTerm(ATerm: string; Editor: IEditor;
  SearchEngine: TSynEditSearchCustom; SearchOptions: TSynSearchOptions);
var
  Indicator: TSynIndicator;
begin
  ClearSearchHighlight(Editor);
  if ATerm = '' then Exit;

  Indicator.Id := SearchHighlightIndicatorId;
  SearchEngine.Options := SearchOptions;
  SearchEngine.Pattern := ATerm;
  SearchEngine.IsWordBreakFunction := Editor.SynEdit.IsWordBreakChar;
  for var I := 0 to Editor.SynEdit.Lines.Count - 1 do begin
    SearchEngine.FindAll(Editor.SynEdit.Lines[I]);

    for var J := 0 to SearchEngine.ResultCount - 1 do begin
      Indicator.CharStart := SearchEngine.Results[J];
      Indicator.CharEnd := Indicator.CharStart + SearchEngine.Lengths[J];
      Editor.SynEdit.Indicators.Add(I + 1, Indicator);
      Editor.SynEdit2.Indicators.Add(I + 1, Indicator);
    end;
  end;
  Editor.HasSearchHighlight := True;
  SearchEngine.IsWordBreakFunction := nil;
  Editor.SynEdit.UpdateScrollBars;
  Editor.SynEdit2.UpdateScrollBars;
end;

end.
