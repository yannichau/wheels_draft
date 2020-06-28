# wheels_draft

'Wheels' is an app designed to provide users with comprehensive route information across multiple bus operators in Hong Kong. 

---

## Getting Started
(Currently unavailable)


---

## Documentation

The following section is the documentation for the development of this application. I attempt to document this project comprehensively, though the format might be slightly informal since this is merely a casual personal project.

### Motivation

Currently, there are mainly 2 companies that operate franchised bus routes in the Hong Kong Island, Kowloon and New Territories regions, namely:
- Kowloon Motor Bus  Co. (1933) Ltd, which operates KMB (Kowloon Motor Bus) and LWB (Long Win Bus); and,
- NWS Holdings, which operates CTB (CityBus) and NWFB (New World First Bus).

Both companies operate a wide range of routes, which can be classified into the following categories:
- Routes within the 3 regions mentioned above, 
- Jointly operated routes, most of which are cross-harbour routes,
- Routes connecting North Lantau and the 3 regions mentioned above; and,
- Other routes, such as border facility routes, racecourse routes and more.

Both companies provide their own apps for accessing information on routes that they operate. The key information that can be accessed in these apps are:
- Route stop information,
- Timetables,
- Mapped locations of routes and their stops,
- Special announcements; and perhaps most importantly,
- ETA (Expected Time of Arrival) information.

While these apps are extremely powerful on their own, they fall short in terms of providing the user with comprehensive information on all bus services in Hong Kong. This is a crucial flaw, in that there is a considerable amount of people that commute in between regions operated by different bus companies. For instance, up until very recently, ETA for jointly operated routes only contained data for the operator's own services, which were not available on the app of the other operator. The reason is both companies use different servers for distributing their data, and they distribute that data in inconsistent APIs, complicating it for open-source developers. Nevertheless, various applications, such as Google Maps, CityMapper and PokeGuide, have incorporated these APIs in their apps to various degrees of success.

### Aims

The app is intended to achieve the aims outlined above. That is, the information offered in the app, are:
- Route stop information,
- Timetables,
- Mapped locations of routes and their stops,
- Special announcements; and perhaps most importantly,
- ETA (Expected Time of Arrival) information.

In addition, to aid the approachability of data, various features are implemented, including a global search method and a favourites function.

I have decided to develop this app on Google's Flutter Platform, since it offers a relatively straightforward manner to implement both frontend and backend features easily. From a development standpoint, developing on Flutter is a refreshing experience, and I feel a greater sense of achievement because I actually get to see the interfaces that I have created. In contrary, I never really actually get to "see" what I have done when I was working on school C++ projects throughout the year, though the things we have achieved with C++ are way more advanced functionality-wise. 

Flutter allows me to spend most of my time developing the backend functionality of the app rather than the frontend interfaces. The high level widgets offered in Flutter are extremely useful for applications that mainly serve the purpose for fetching data, and the interfaces achieved are indeed consistent with typical Material-style apps. Most importantly of all, these widgets are compatible across both iOS and Android platforms, which means that it can potentially reach quite a bit of users (though at this point this is probably quite far-fetched provided my current progress on the project).

One thing to note is that I have never intended to develop this application to replace highly-versatile transit apps such as Google Maps or CityMapper. These applications rely on highly vetted algorithms to provide information for directions, in which incorporating APIs for bus ETA is merely a small part; such functionality is highly advanced and indeed quite unachievable without the large databases that these companies have specifically created for these purposes. Instead, this is merely an attempt for me to develop an application that brings together the functionality of different bus operators' apps, in a hopefully clean and efficient manner.

## Stages of Development


## APIs


## References

(Nope, this is not cited in a proper IEEE/Chicago/MLA/whatever standard, but I do want to acknowledge the things I have read to work on this project.)
