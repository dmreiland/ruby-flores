# encoding: utf-8
# This file is part of ruby-flores.
# Copyright (C) 2015 Jordan Sissel
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
require "spec_init"

shared_examples_for String do
  stress_it "should be a String" do
    expect(subject).to(be_a(String))
  end
  stress_it "have expected encoding" do
    expect(subject.encoding).to(be == Encoding.default_external)
  end
  stress_it "have valid encoding" do
    expect(subject).to(be_valid_encoding)
  end
end

describe Flores::Random do
  analyze_results

  describe "#text" do
    context "with no arguments" do
      stress_it "should raise ArgumentError" do
        expect { subject.text }.to(raise_error(ArgumentError))
      end
    end

    context "with 1 length argument" do
      subject { described_class.text(length) }

      context "that is positive" do
        let(:length) { Flores::Random.integer(1..1000) }
        it_behaves_like String, [:length]
        stress_it "has correct length" do
          expect(subject.length).to(eq(length))
        end

        stress_it "has correct encoding" do
          expect(subject.encoding).to(be == Encoding.default_external)
        end
      end

      context "that is negative" do
        let(:length) { -1 * Flores::Random.integer(1..1000) }
        stress_it "should raise ArgumentError" do
          expect { subject }.to(raise_error(ArgumentError))
        end
      end
    end

    context "with 1 range argument" do
      let(:start)  { Flores::Random.integer(2..1000) }
      let(:length) { Flores::Random.integer(1..1000) }
      subject { described_class.text(range) }

      context "that is ascending" do
        let(:range) { start..(start + length) }
        it_behaves_like String, [:range]
        stress_it "should give a string within that length range" do
          expect(subject).to(be_a(String))
          expect(range).to(include(subject.length))
        end
      end

      context "that is descending" do
        let(:range) { start..(start - length) }
        stress_it "should raise ArgumentError" do
          expect { subject }.to(raise_error(ArgumentError))
        end
      end
    end
  end

  describe "#character" do
    subject { described_class.character }
    it_behaves_like String, [:subject]
    stress_it "has length == 1" do
      expect(subject.length).to(be == 1)
    end
  end

  shared_examples_for Numeric do |type|
    let(:start) { Flores::Random.integer(-100_000..100_000) }
    let(:length) { Flores::Random.integer(1..100_000) }
    let(:range) { start..(start + length) }

    stress_it "should be a #{type}" do
      expect(subject).to(be_a(type))
    end

    stress_it "should be within the bounds of the given range" do
      expect(range).to(include(subject))
    end
  end

  describe "#integer" do
    it_behaves_like Numeric, Fixnum do
      subject { Flores::Random.integer(range) }
    end
  end

  describe "#number" do
    it_behaves_like Numeric, Float do
      subject { Flores::Random.number(range) }
    end
  end

  describe "#iterations" do
    let(:start) { Flores::Random.integer(1..1000) }
    let(:length) { Flores::Random.integer(1..1000) }
    let(:range) { start..(start + length) }
    subject { Flores::Random.iterations(range) }

    stress_it "should return an Enumerable" do
      expect(subject).to(be_a(Enumerable))
    end

    stress_it "should have a size within the expected range" do
      # Ruby 2.0 added Enumerable#size, so we can't use it here.
      # Meaning `123.times.size` doesn't work. So for this test,
      # we use small ranges because Enumerable#count actually
      # counts (via iteration) and is slow on large numbers.
      expect(range).to(include(subject.count))
    end
  end

  describe "#items" do
    let(:start) { Flores::Random.integer(1..1000) }
    let(:length) { Flores::Random.integer(1..1000) }
    let(:range) { start..(start + length) }
    let(:items) { Flores::Random.iterations(range).collect { Flores::Random.number(1..1000) } }
    subject { Flores::Random.item(items) }

    stress_it "should choose a random item from the list" do
      expect(items).to(include(subject))
    end

    context "with a list of numbers" do
      stress_it "should be return a number" do
        expect(subject).to(be_a(Numeric))
      end
    end
  end
end 
