//
//  TestTabViewController.swift
//  NewsApp
//
//  Created by Microos on 2020/4/29.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner

class TestTabViewController: UIViewController {
    
    
    
    @IBOutlet weak var textview: UILabel!
    
    @IBAction func button3(_ sender: UIButton) {
        BookmarkManager.removeAll()
        self.warningToast("Number of bookmarks reset to: \(BookmarkManager.loadBookmarks().count)")
    }
    @IBAction func button2(_ sender: UIButton) {
        let html = "<p>When the Spanish illustrator <a href=\"https://www.behance.net/cristinadaura\">Cristina Daura</a> was asked to contribute to a collection of artistic works to mark the <a href=\"https://www.theguardian.com/world/ve-day\">75th anniversary of VE Day</a> it was a challenge.</p> <p>The idea of victory in war begged the question: at what cost? At 31, Daura, whose vibrant illustrations have featured in exhibitions, books, magazines and newspapers around the world, had not lived through the second world war.</p> <p>But, she reasoned, she had lived through the relative peace in Europe since its ending. So she chose positivity as her theme, “examining how to preserve that peace and sustain the calm that followed such a tough and violent situation”.</p> <p>Her work now forms part of an online exhibition of interpretations of Victory in Europe, from poetry, to spoken word and music, created by a range of contemporary artists specially commissioned by the <a href=\"https://www.iwm.org.uk/\">IWM</a> (Imperial War Museums).</p> <p>The works <a href=\"https://www.iwm.org.uk/history/victory\">will be launched on Friday’s anniversary</a><a href=\"https://www.iwm.org.uk/history/victory\">, on the IWM website,</a> as part of its Voices of War exhibition featuring a selection of first-hand accounts of the end of the second world war from the museum’s sound archives.</p>  <figure class=\"element element-image element--supporting\" data-media-id=\"3c04a7acb2968f759e9d76b83ea1d5789fb735a0\"> <img src=\"https://media.guim.co.uk/3c04a7acb2968f759e9d76b83ea1d5789fb735a0/1_0_477_596/400.jpg\" alt=\"Cristina Daura\" width=\"400\" height=\"500\" class=\"gu-image\" /> <figcaption> <span class=\"element-image__caption\">Cristina Daura.</span> <span class=\"element-image__credit\">Photograph: youtube</span> </figcaption> </figure>  <p>Barcelona-based Daura said: “Victory can be seen as something strong. But, at the same time fragile. It’s not something we are given for free.”</p> <p>She has captioned her bold, colourful, abstract work, entitled Victory, with the message she aims to convey: “Victory is both a strong and a fragile concept. The illustration depicts victory achieved at the end of conflict as if it were a seed that must be nurtured in order to thrive. Like a flower, victory must be taken care of in order to be re-gifted to future generations.”</p> <p>The <a href=\"https://www.amnesty.org.uk/charlie-dark\">DJ, poet and writer, Charlie Dark</a> took as inspiration Churchill’s VE Day speech for his poem A Brief Period of Rejoicing. The founder of the cult running club Run Dem Crew was struck by comparisons with the current situation under lockdown and anticipation of it ending. In particular, the fleeting moment of euphoria of the ending of a period of uncertainty or danger, swiftly followed by the realisation of the extent of the rebuilding process.</p> <p>The <a href=\"https://www.theguardian.com/artanddesign/2016/aug/25/meet-the-artists-making-women-of-colour-truly-seen\">poet Rachel Long</a> based her interpretation, Weather Forecast, March-May 2020, on the VE day weather report by the BBC’s Stuart Hibberd. Long said: “It uses elements of the report style, and weather as a metaphor, for what is happening in the world now – the weather 75 years later. I wanted to record my voice only, as a wireless-style mirroring of VE day weather report.”</p> <p><a href=\"https://www.theguardian.com/profile/daljitnagra\">Daljit Nagra</a>, BBC Radio 4’s first poet-in-residence, explores the innocent people caught up on the wrong side who had no voice, while the <a href=\"https://www.chanjekunda.com/\">performance artist Chanje Kunda</a> contrasts conflicting emotions of relief, excitement, and the joyous cheers and celebration in the street with the shock and pain of losing loved ones. <a href=\"https://www.bbc.co.uk/bitesize/articles/zjyr382\">Amina Atiq, </a>a Yemeni-Scouse writer and activist, questions what victory means today, and who it belongs to.</p> <p>Originally, the IWM planned to broadcast its Voices of War exhibition in select public places, as well as on its website, but the Covid-19 pandemic prevented that.</p> <p>Diane Lees, the IWM director general, said: “We want the public to reflect on this important historical milestone as many others did 75 years ago – in the privacy of their own kitchens, living rooms, bedrooms and gardens – and be part of this important national moment with IWM and with the rest of the country.”</p>"
        
        self.textview.setHTML(html)
        self.textview.numberOfLines = 10
        self.textview.lineBreakMode = .byTruncatingTail
        
    }
    
    @IBAction func button1(_ sender: Any) {
        TrendingAPI.requestTrendingData(q: "tencent", completion: {
            result in
            switch result{
            case .success(let arr):
                self.regularToast("\(arr)")
            case .failure(let err):
                self.errorToast("\(err)")
            }
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //SwiftSpinner.show("Loading Home Page...", animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}
