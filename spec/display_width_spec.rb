# coding: utf-8

require 'unicode/display_width'

describe 'Unicode::DisplayWidth.for' do
  describe '[east asian width]' do
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

  describe '[general category]' do
    it 'returns 1 for non-special (non east width) chars' do
      expect( 'A'.display_width ).to eq 1
    end

    it 'returns 0 for Mn chars' do
      expect( 'ֿ'.display_width ).to eq 0
    end
  end

  describe 'overwrite' do
    it 'can be passed a 3rd parameter that contains a hash with overwrites' do
      expect( "\t".display_width(1, 0x09 => 12) ).to eq 12
    end
  end
end
