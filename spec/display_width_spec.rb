# coding: utf-8

require 'unicode/display_width'

describe Unicode::DisplayWidth do
  describe 'String#display_width' do
    it 'returns 2 for F chars' do
      expect( '！'.display_width ).to eq 2
    end

    it 'returns 2 for W chars' do
      expect( '一'.display_width ).to eq 2
    end

    it 'returns 1 for N chars' do
      expect( 'À'.display_width ).to eq 1
    end

    it 'returns 1 for Na chars' do
      expect( 'A'.display_width ).to eq 1
    end

    it 'returns 1 for H chars' do
      expect( '｡'.display_width ).to eq 1
    end

    it 'returns first argument of display_width for A chars' do
      expect( '·'.display_width(2) ).to eq 2
    end
  end
end
