//
//  UniversityData.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation

struct UniversityData {
    static let sampleUniversities: [University] = [
        // California
        University(name: "University of Southern California", state: "California", city: "Los Angeles", hasChapter: true, studentPopulation: 47310, website: "usc.edu"),
        University(name: "University of California, Los Angeles", state: "California", city: "Los Angeles", hasChapter: true, studentPopulation: 46116, website: "ucla.edu"),
        University(name: "Stanford University", state: "California", city: "Stanford", hasChapter: true, studentPopulation: 17249, website: "stanford.edu"),
        University(name: "University of California, Berkeley", state: "California", city: "Berkeley", hasChapter: true, studentPopulation: 45057, website: "berkeley.edu"),
        University(name: "University of California, San Diego", state: "California", city: "San Diego", hasChapter: true, studentPopulation: 42875, website: "ucsd.edu"),
        University(name: "California Institute of Technology", state: "California", city: "Pasadena", hasChapter: false, studentPopulation: 2397, website: "caltech.edu"),
        
        // Texas
        University(name: "University of Texas at Austin", state: "Texas", city: "Austin", hasChapter: true, studentPopulation: 51991, website: "utexas.edu"),
        University(name: "Texas A&M University", state: "Texas", city: "College Station", hasChapter: true, studentPopulation: 74014, website: "tamu.edu"),
        University(name: "University of Houston", state: "Texas", city: "Houston", hasChapter: true, studentPopulation: 47027, website: "uh.edu"),
        University(name: "Southern Methodist University", state: "Texas", city: "Dallas", hasChapter: true, studentPopulation: 12393, website: "smu.edu"),
        University(name: "Texas Christian University", state: "Texas", city: "Fort Worth", hasChapter: true, studentPopulation: 11525, website: "tcu.edu"),
        University(name: "Rice University", state: "Texas", city: "Houston", hasChapter: false, studentPopulation: 8101, website: "rice.edu"),
        
        // Florida
        University(name: "University of Florida", state: "Florida", city: "Gainesville", hasChapter: true, studentPopulation: 56567, website: "ufl.edu"),
        University(name: "Florida State University", state: "Florida", city: "Tallahassee", hasChapter: true, studentPopulation: 44075, website: "fsu.edu"),
        University(name: "University of Miami", state: "Florida", city: "Coral Gables", hasChapter: true, studentPopulation: 19096, website: "miami.edu"),
        University(name: "University of Central Florida", state: "Florida", city: "Orlando", hasChapter: true, studentPopulation: 68442, website: "ucf.edu"),
        University(name: "University of South Florida", state: "Florida", city: "Tampa", hasChapter: true, studentPopulation: 50755, website: "usf.edu"),
        University(name: "Florida International University", state: "Florida", city: "Miami", hasChapter: false, studentPopulation: 56851, website: "fiu.edu"),
        
        // New York
        University(name: "Columbia University", state: "New York", city: "New York", hasChapter: true, studentPopulation: 33413, website: "columbia.edu"),
        University(name: "New York University", state: "New York", city: "New York", hasChapter: true, studentPopulation: 59144, website: "nyu.edu"),
        University(name: "Cornell University", state: "New York", city: "Ithaca", hasChapter: true, studentPopulation: 25593, website: "cornell.edu"),
        University(name: "Syracuse University", state: "New York", city: "Syracuse", hasChapter: true, studentPopulation: 22698, website: "syracuse.edu"),
        University(name: "University at Buffalo", state: "New York", city: "Buffalo", hasChapter: false, studentPopulation: 32347, website: "buffalo.edu"),
        University(name: "Fordham University", state: "New York", city: "New York", hasChapter: false, studentPopulation: 16556, website: "fordham.edu"),
        
        // Pennsylvania
        University(name: "Pennsylvania State University", state: "Pennsylvania", city: "State College", hasChapter: true, studentPopulation: 99390, website: "psu.edu"),
        University(name: "University of Pennsylvania", state: "Pennsylvania", city: "Philadelphia", hasChapter: true, studentPopulation: 28201, website: "upenn.edu"),
        University(name: "University of Pittsburgh", state: "Pennsylvania", city: "Pittsburgh", hasChapter: true, studentPopulation: 33767, website: "pitt.edu"),
        University(name: "Temple University", state: "Pennsylvania", city: "Philadelphia", hasChapter: true, studentPopulation: 39419, website: "temple.edu"),
        University(name: "Carnegie Mellon University", state: "Pennsylvania", city: "Pittsburgh", hasChapter: false, studentPopulation: 15818, website: "cmu.edu"),
        University(name: "Drexel University", state: "Pennsylvania", city: "Philadelphia", hasChapter: false, studentPopulation: 22344, website: "drexel.edu"),
        
        // Ohio
        University(name: "Ohio State University", state: "Ohio", city: "Columbus", hasChapter: true, studentPopulation: 66444, website: "osu.edu"),
        University(name: "University of Cincinnati", state: "Ohio", city: "Cincinnati", hasChapter: true, studentPopulation: 46388, website: "uc.edu"),
        University(name: "Case Western Reserve University", state: "Ohio", city: "Cleveland", hasChapter: true, studentPopulation: 12201, website: "case.edu"),
        University(name: "Miami University", state: "Ohio", city: "Oxford", hasChapter: true, studentPopulation: 19107, website: "miamioh.edu"),
        University(name: "Ohio University", state: "Ohio", city: "Athens", hasChapter: false, studentPopulation: 28990, website: "ohio.edu"),
        University(name: "Kent State University", state: "Ohio", city: "Kent", hasChapter: false, studentPopulation: 34284, website: "kent.edu"),
        
        // Illinois
        University(name: "University of Illinois at Urbana-Champaign", state: "Illinois", city: "Champaign", hasChapter: true, studentPopulation: 56607, website: "illinois.edu"),
        University(name: "Northwestern University", state: "Illinois", city: "Evanston", hasChapter: true, studentPopulation: 23466, website: "northwestern.edu"),
        University(name: "University of Chicago", state: "Illinois", city: "Chicago", hasChapter: true, studentPopulation: 18452, website: "uchicago.edu"),
        University(name: "DePaul University", state: "Illinois", city: "Chicago", hasChapter: false, studentPopulation: 21900, website: "depaul.edu"),
        University(name: "Loyola University Chicago", state: "Illinois", city: "Chicago", hasChapter: false, studentPopulation: 17358, website: "luc.edu"),
        
        // Michigan
        University(name: "University of Michigan", state: "Michigan", city: "Ann Arbor", hasChapter: true, studentPopulation: 51225, website: "umich.edu"),
        University(name: "Michigan State University", state: "Michigan", city: "East Lansing", hasChapter: true, studentPopulation: 50023, website: "msu.edu"),
        University(name: "Wayne State University", state: "Michigan", city: "Detroit", hasChapter: true, studentPopulation: 26251, website: "wayne.edu"),
        University(name: "Western Michigan University", state: "Michigan", city: "Kalamazoo", hasChapter: false, studentPopulation: 22960, website: "wmich.edu"),
        
        // Arizona
        University(name: "Arizona State University", state: "Arizona", city: "Tempe", hasChapter: true, studentPopulation: 80065, website: "asu.edu"),
        University(name: "University of Arizona", state: "Arizona", city: "Tucson", hasChapter: true, studentPopulation: 49471, website: "arizona.edu"),
        University(name: "Northern Arizona University", state: "Arizona", city: "Flagstaff", hasChapter: true, studentPopulation: 30307, website: "nau.edu"),
        
        // Georgia
        University(name: "University of Georgia", state: "Georgia", city: "Athens", hasChapter: true, studentPopulation: 40118, website: "uga.edu"),
        University(name: "Georgia Institute of Technology", state: "Georgia", city: "Atlanta", hasChapter: true, studentPopulation: 45296, website: "gatech.edu"),
        University(name: "Georgia State University", state: "Georgia", city: "Atlanta", hasChapter: true, studentPopulation: 53908, website: "gsu.edu"),
        University(name: "Emory University", state: "Georgia", city: "Atlanta", hasChapter: false, studentPopulation: 15441, website: "emory.edu"),
        
        // North Carolina
        University(name: "University of North Carolina", state: "North Carolina", city: "Chapel Hill", hasChapter: true, studentPopulation: 31641, website: "unc.edu"),
        University(name: "Duke University", state: "North Carolina", city: "Durham", hasChapter: true, studentPopulation: 18023, website: "duke.edu"),
        University(name: "North Carolina State University", state: "North Carolina", city: "Raleigh", hasChapter: true, studentPopulation: 36304, website: "ncsu.edu"),
        University(name: "Wake Forest University", state: "North Carolina", city: "Winston-Salem", hasChapter: false, studentPopulation: 9000, website: "wfu.edu"),
        
        // Virginia
        University(name: "University of Virginia", state: "Virginia", city: "Charlottesville", hasChapter: true, studentPopulation: 25628, website: "virginia.edu"),
        University(name: "Virginia Tech", state: "Virginia", city: "Blacksburg", hasChapter: true, studentPopulation: 37024, website: "vt.edu"),
        University(name: "Virginia Commonwealth University", state: "Virginia", city: "Richmond", hasChapter: true, studentPopulation: 30142, website: "vcu.edu"),
        University(name: "George Mason University", state: "Virginia", city: "Fairfax", hasChapter: false, studentPopulation: 39852, website: "gmu.edu"),
        
        // Washington
        University(name: "University of Washington", state: "Washington", city: "Seattle", hasChapter: true, studentPopulation: 52191, website: "washington.edu"),
        University(name: "Washington State University", state: "Washington", city: "Pullman", hasChapter: true, studentPopulation: 31607, website: "wsu.edu"),
        University(name: "Seattle University", state: "Washington", city: "Seattle", hasChapter: false, studentPopulation: 7245, website: "seattleu.edu"),
        
        // Colorado
        University(name: "University of Colorado Boulder", state: "Colorado", city: "Boulder", hasChapter: true, studentPopulation: 39461, website: "colorado.edu"),
        University(name: "Colorado State University", state: "Colorado", city: "Fort Collins", hasChapter: true, studentPopulation: 34166, website: "colostate.edu"),
        University(name: "University of Denver", state: "Colorado", city: "Denver", hasChapter: false, studentPopulation: 14002, website: "du.edu"),
        
        // Wisconsin
        University(name: "University of Wisconsin-Madison", state: "Wisconsin", city: "Madison", hasChapter: true, studentPopulation: 48956, website: "wisc.edu"),
        University(name: "Marquette University", state: "Wisconsin", city: "Milwaukee", hasChapter: true, studentPopulation: 11396, website: "marquette.edu"),
        University(name: "University of Wisconsin-Milwaukee", state: "Wisconsin", city: "Milwaukee", hasChapter: false, studentPopulation: 24402, website: "uwm.edu"),
        
        // Massachusetts
        University(name: "Massachusetts Institute of Technology", state: "Massachusetts", city: "Cambridge", hasChapter: true, studentPopulation: 11934, website: "mit.edu"),
        University(name: "Boston University", state: "Massachusetts", city: "Boston", hasChapter: true, studentPopulation: 36714, website: "bu.edu"),
        University(name: "Harvard University", state: "Massachusetts", city: "Cambridge", hasChapter: false, studentPopulation: 31655, website: "harvard.edu"),
        University(name: "Tufts University", state: "Massachusetts", city: "Medford", hasChapter: false, studentPopulation: 12980, website: "tufts.edu"),
        
        // Tennessee
        University(name: "University of Tennessee", state: "Tennessee", city: "Knoxville", hasChapter: true, studentPopulation: 33805, website: "utk.edu"),
        University(name: "Vanderbilt University", state: "Tennessee", city: "Nashville", hasChapter: true, studentPopulation: 13796, website: "vanderbilt.edu"),
        University(name: "University of Memphis", state: "Tennessee", city: "Memphis", hasChapter: false, studentPopulation: 21679, website: "memphis.edu"),
        
        // Indiana
        University(name: "Indiana University", state: "Indiana", city: "Bloomington", hasChapter: true, studentPopulation: 47695, website: "indiana.edu"),
        University(name: "Purdue University", state: "Indiana", city: "West Lafayette", hasChapter: true, studentPopulation: 50884, website: "purdue.edu"),
        University(name: "University of Notre Dame", state: "Indiana", city: "Notre Dame", hasChapter: false, studentPopulation: 12809, website: "nd.edu"),
        
        // Missouri
        University(name: "University of Missouri", state: "Missouri", city: "Columbia", hasChapter: true, studentPopulation: 31304, website: "missouri.edu"),
        University(name: "Washington University in St. Louis", state: "Missouri", city: "St. Louis", hasChapter: false, studentPopulation: 16550, website: "wustl.edu"),
        University(name: "Missouri State University", state: "Missouri", city: "Springfield", hasChapter: false, studentPopulation: 24485, website: "missouristate.edu"),
        
        // Alabama
        University(name: "University of Alabama", state: "Alabama", city: "Tuscaloosa", hasChapter: true, studentPopulation: 38644, website: "ua.edu"),
        University(name: "Auburn University", state: "Alabama", city: "Auburn", hasChapter: true, studentPopulation: 31764, website: "auburn.edu"),
        University(name: "University of Alabama at Birmingham", state: "Alabama", city: "Birmingham", hasChapter: true, studentPopulation: 22563, website: "uab.edu"),
        University(name: "Alabama State University", state: "Alabama", city: "Montgomery", hasChapter: true, studentPopulation: 4741, website: "alasu.edu")
    ]
}
